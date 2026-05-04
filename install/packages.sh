#!/usr/bin/env bash
# Package manifest helpers for dotfiles installers.

set -euo pipefail

if [[ -n "${DOTS_PACKAGES_SH_SOURCED:-}" ]]; then
    return 0 2>/dev/null || exit 0
fi
DOTS_PACKAGES_SH_SOURCED=1

if [[ -z "${DOTS_LIB_DIR:-}" ]]; then
    SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    source "${SCRIPT_DIR}/lib.sh"
fi

readonly DOTS_PACKAGE_MANAGER=(sudo pacman -Syu --needed --noconfirm)
readonly DOTS_AUR_HELPER=(yay -Syu --needed --noconfirm)
readonly DOTS_PACKAGE_NAME_PATTERN='^[A-Za-z0-9@._+-]+$'

_trim_package_line() {
    local line="$1"
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    printf '%s\n' "$line"
}

collect_package_files() {
    local -n package_files_ref="$1"
    shift

    local -a found_package_files=()
    local path pkg_file

    for path in "$@"; do
        if [[ -f "$path" ]]; then
            found_package_files+=("$path")
        elif [[ -d "$path" ]]; then
            while IFS= read -r pkg_file; do
                found_package_files+=("$pkg_file")
            done < <(find "$path" -name "pkg.txt" -print 2>/dev/null)
        fi
    done

    if (( ${#found_package_files[@]} == 0 )); then
        package_files_ref=()
        return 0
    fi

    mapfile -t package_files_ref < <(printf '%s\n' "${found_package_files[@]}" | sort -u)
}

collect_packages() {
    local package_type="$1"
    local -n packages_ref="$2"
    shift 2

    local -a manifest_files=()
    local -a packages=()
    local pkg_file line package_name

    collect_package_files manifest_files "$@"

    for pkg_file in "${manifest_files[@]}"; do
        while IFS= read -r line || [[ -n "$line" ]]; do
            line="$(_trim_package_line "$line")"
            [[ -z "$line" ]] && continue

            case "$package_type" in
                repo)
                    [[ "$line" == aur:* ]] && continue
                    packages+=("$line")
                    ;;
                aur)
                    [[ "$line" == aur:* ]] || continue
                    packages+=("${line#aur:}")
                    ;;
                *)
                    error "Unknown package type: $package_type"
                    return 1
                    ;;
            esac
        done < "$pkg_file"
    done

    if (( ${#packages[@]} == 0 )); then
        packages_ref=()
        return 0
    fi

    mapfile -t packages_ref < <(printf '%s\n' "${packages[@]}" | sort -u)
}

validate_package_manifests() {
    local -a manifest_files=()
    local pkg_file line package_name
    local failures=0

    collect_package_files manifest_files "$@"

    for pkg_file in "${manifest_files[@]}"; do
        local line_number=0
        while IFS= read -r line || [[ -n "$line" ]]; do
            line_number=$((line_number + 1))
            package_name="$(_trim_package_line "$line")"
            [[ -z "$package_name" ]] && continue

            if [[ "$package_name" == aur:* ]]; then
                package_name="${package_name#aur:}"
                if [[ -z "$package_name" ]]; then
                    error "${pkg_file}:${line_number}: aur package entry is missing a package name"
                    failures=$((failures + 1))
                    continue
                fi
            fi

            if [[ ! "$package_name" =~ $DOTS_PACKAGE_NAME_PATTERN ]]; then
                error "${pkg_file}:${line_number}: invalid package entry '${line}'"
                failures=$((failures + 1))
            fi
        done < "$pkg_file"
    done

    (( failures == 0 ))
}

ensure_yay() {
    command -v yay &>/dev/null && return 0
    local tmp_dir="${HOME}/yay"
    info "yay not found. Installing..."
    trap 'rm -rf "$tmp_dir"' EXIT
    git clone https://aur.archlinux.org/yay.git "$tmp_dir"
    (cd "$tmp_dir" && makepkg -si --noconfirm)
}

install_repo_packages() {
    local -a pkgs=("$@")
    (( ${#pkgs[@]} == 0 )) && return 0
    info "Installing ${#pkgs[@]} packages..."
    "${DOTS_PACKAGE_MANAGER[@]}" "${pkgs[@]}"
}

install_aur_packages() {
    local -a pkgs=("$@")
    (( ${#pkgs[@]} == 0 )) && return 0
    info "Installing ${#pkgs[@]} AUR packages..."
    "${DOTS_AUR_HELPER[@]}" "${pkgs[@]}"
}

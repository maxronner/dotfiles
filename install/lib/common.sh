#!/usr/bin/env bash

set -euo pipefail

readonly COMMON_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd -- "${COMMON_DIR}/../.." && pwd)"
readonly HOME_DIR="${HOME:-/home/$(whoami)}"
readonly DEVICES_DIR="${REPO_ROOT}/devices"

readonly PACKAGE_MANAGER=(sudo pacman -Syu --needed --noconfirm)
readonly AUR_HELPER=(yay -Syu --needed --noconfirm)

info() {
    printf "\033[1;34m[INFO]\033[0m %s\n" "$@"
}

success() {
    printf "\033[1;32m[SUCCESS]\033[0m %s\n" "$@"
}

warn() {
    printf "\033[1;33m[WARN]\033[0m %s\n" "$@"
}

error() {
    printf "\033[1;31m[ERROR]\033[0m %s\n" "$@" >&2
}

install_packages() {
    local label="$1"
    local manager_name="$2"
    shift 2

    local packages=("$@")

    (( ${#packages[@]} == 0 )) && return 0

    local -n manager_ref="$manager_name"
    info "Installing ${#packages[@]} ${label}..."
    "${manager_ref[@]}" "${packages[@]}"
}

install_repo_packages() {
    install_packages "packages" PACKAGE_MANAGER "$@"
}

install_aur_packages() {
    install_packages "AUR packages" AUR_HELPER "$@"
}

populate_pkg_search_dirs() {
    local env_name="${1:-}"
    local -n dirs_ref="$2"

    dirs_ref=("${REPO_ROOT}/apps" "${REPO_ROOT}/system")

    if [[ -n "$env_name" ]]; then
        dirs_ref+=("${DEVICES_DIR}/${env_name}")
    fi
}

resolve_profile() {
    local requested_profile="${1:-}"
    local -n profile_ref="$2"

    profile_ref=""

    if [[ -z "$requested_profile" ]]; then
        return 0
    fi

    if [[ ! -d "${DEVICES_DIR}/${requested_profile}" ]]; then
        warn "Unknown profile: ${requested_profile} — falling back to baseline"
        warn "Available profiles:"
        local profile_dir
        for profile_dir in "${DEVICES_DIR}"/*; do
            [[ -d "$profile_dir" ]] || continue
            warn "- $(basename "$profile_dir")"
        done
        return 0
    fi

    profile_ref="$requested_profile"
}

collect_pkg_entries() {
    local package_type="$1"
    local env_name="${2:-}"
    local -n packages_ref="$3"

    local -a search_dirs=()
    local -a pkg_files=()
    local -a packages=()
    local line

    populate_pkg_search_dirs "$env_name" search_dirs
    mapfile -t pkg_files < <(find "${search_dirs[@]}" -name "pkg.txt" -print)

    for pkg_file in "${pkg_files[@]}"; do
        while IFS= read -r line || [[ -n "$line" ]]; do
            line="${line%%#*}"
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"

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

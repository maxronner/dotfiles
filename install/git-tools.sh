#!/usr/bin/env bash
# Install simple tools from git repositories described by manifest files.

set -euo pipefail

git_tool_source_root() {
    printf '%s\n' "${DOTS_GIT_TOOLS_DIR:-${HOME}/.local/src/dotfiles/git-tools}"
}

validate_git_tool_name() {
    local name="$1"
    [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]]
}

sync_git_tool_source() {
    local name="$1"
    local repo="$2"
    local ref="$3"
    local source_dir

    validate_git_tool_name "$name" || {
        error "Invalid git tool name: ${name}"
        return 1
    }

    source_dir="$(git_tool_source_root)/${name}"
    mkdir -p "$(dirname "$source_dir")"

    if [[ ! -d "${source_dir}/.git" ]]; then
        git clone "$repo" "$source_dir" || return 1
    else
        git -C "$source_dir" remote set-url origin "$repo"
        git -C "$source_dir" fetch --tags --prune origin >/dev/null || return 1
    fi

    if [[ "$ref" == "-" ]]; then
        git -C "$source_dir" pull --ff-only >/dev/null || return 1
    else
        git -C "$source_dir" checkout "$ref" >/dev/null || return 1
    fi

    printf '%s\n' "$source_dir"
}

install_git_tool_manifest() {
    local manifest="${1:?Usage: install_git_tool_manifest <manifest>}"
    local line name command_name repo ref install_command source_dir

    [[ -f "$manifest" ]] || return 0

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -n "$line" && "$line" != \#* ]] || continue

        IFS='|' read -r name command_name repo ref install_command <<< "$line"
        if [[ -z "${name:-}" || -z "${command_name:-}" || -z "${repo:-}" || -z "${ref:-}" || -z "${install_command:-}" ]]; then
            error "Invalid git tool manifest entry in ${manifest}: ${line}"
            return 1
        fi

        info "Installing git tool ${name} from ${repo}..."
        (
            source_dir="$(sync_git_tool_source "$name" "$repo" "$ref")" || exit 1
            cd "$source_dir"
            bash -lc "$install_command"
        ) || {
            error "Failed to install git tool ${name}; continuing."
        }
    done < "$manifest"
}

install_git_tool_manifests() {
    local manifest
    for manifest in "$@"; do
        install_git_tool_manifest "$manifest"
    done
}

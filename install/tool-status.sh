#!/usr/bin/env bash
# Report how local tool commands resolve on PATH.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/tool-source.sh"

repo_command_path() {
    local command_name="$1"
    printf '%s/local/dot-local/bin/%s\n' "$DOTS_DIR" "$command_name"
}

report_command() {
    local command_name="$1"
    local resolved
    local repo_path
    local version

    repo_path="$(repo_command_path "$command_name")"

    if ! resolved="$(command -v "$command_name" 2>/dev/null)"; then
        printf '%-16s missing\n' "$command_name"
        return 1
    fi

    if [[ "$(readlink -f -- "$resolved")" == "$(readlink -f -- "$repo_path")" ]]; then
        printf '%-16s repo-fallback %s\n' "$command_name" "$resolved"
    else
        printf '%-16s installed     %s\n' "$command_name" "$resolved"
    fi

    if [[ "$command_name" == "thememanager" ]]; then
        local source_dir
        source_dir="$(resolve_thememanager_source)"
        printf '%-16s package-source  %s %s\n' "" "$(describe_thememanager_source "$source_dir")" "$source_dir"

        version="$("$resolved" --version 2>/dev/null || true)"
        if [[ -n "$version" ]]; then
            printf '%-16s package-version %s\n' "" "$version"
        else
            printf '%-16s package-version unavailable\n' ""
        fi
    fi
}

status=0
report_command thememanager || status=1
report_command color256 || status=1
report_command theme-apply-all || status=1

exit "$status"

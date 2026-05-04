#!/usr/bin/env bash
# Resolve package source directories for local tools.

set -euo pipefail

resolve_thememanager_source() {
    local override="${THEMEMANAGER_SOURCE_DIR:-}"
    local standalone="${HOME_DIR}/code/thememanager"
    local bundled="${DOTS_DIR}/tools/thememanager"

    if [[ -n "$override" ]]; then
        if [[ -f "${override}/pyproject.toml" ]]; then
            printf '%s\n' "$override"
            return 0
        fi

        error "THEMEMANAGER_SOURCE_DIR is not a thememanager package: ${override}"
        return 1
    fi

    if [[ -f "${standalone}/pyproject.toml" ]]; then
        printf '%s\n' "$standalone"
        return 0
    fi

    printf '%s\n' "$bundled"
}

describe_thememanager_source() {
    local source_dir="$1"
    local standalone="${HOME_DIR}/code/thememanager"
    local bundled="${DOTS_DIR}/tools/thememanager"

    if [[ "$(realpath -m -- "$source_dir")" == "$(realpath -m -- "$standalone")" ]]; then
        printf 'standalone'
    elif [[ "$(realpath -m -- "$source_dir")" == "$(realpath -m -- "$bundled")" ]]; then
        printf 'bundled'
    else
        printf 'custom'
    fi
}

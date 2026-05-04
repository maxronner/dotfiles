#!/usr/bin/env bash
# Resolve package install targets for local tools.

set -euo pipefail

THEMEMANAGER_RELEASE_VERSION="0.1.0"
THEMEMANAGER_RELEASE_TAG="v${THEMEMANAGER_RELEASE_VERSION}"

resolve_thememanager_bundled_source() {
    printf '%s/tools/thememanager\n' "$DOTS_DIR"
}

resolve_thememanager_release_spec() {
    local standalone="${HOME_DIR}/code/thememanager"

    if [[ -f "${standalone}/pyproject.toml" ]] &&
       git -C "$standalone" rev-parse -q --verify "refs/tags/${THEMEMANAGER_RELEASE_TAG}" >/dev/null 2>&1; then
        printf 'git+file://%s@%s\n' "$standalone" "$THEMEMANAGER_RELEASE_TAG"
        return 0
    fi

    return 1
}

resolve_thememanager_install_spec() {
    local install_spec="${THEMEMANAGER_INSTALL_SPEC:-}"
    local override="${THEMEMANAGER_SOURCE_DIR:-}"

    if [[ -n "$install_spec" ]]; then
        printf '%s\n' "$install_spec"
        return 0
    fi

    if [[ -n "$override" ]]; then
        if [[ -f "${override}/pyproject.toml" ]]; then
            printf '%s\n' "$override"
            return 0
        fi

        error "THEMEMANAGER_SOURCE_DIR is not a thememanager package: ${override}"
        return 1
    fi

    if resolve_thememanager_release_spec; then
        return 0
    fi

    resolve_thememanager_bundled_source
}

resolve_thememanager_build_source() {
    resolve_thememanager_bundled_source
}

describe_thememanager_install_spec() {
    local install_spec="$1"
    local bundled="${DOTS_DIR}/tools/thememanager"

    if [[ "$install_spec" == git+file://*@${THEMEMANAGER_RELEASE_TAG} ]]; then
        printf 'release'
    elif [[ -f "${install_spec}/pyproject.toml" ]] &&
         [[ "$(realpath -m -- "$install_spec")" == "$(realpath -m -- "$bundled")" ]]; then
        printf 'bundled'
    elif [[ -f "${install_spec}/pyproject.toml" ]]; then
        printf 'source'
    else
        printf 'custom'
    fi
}

#!/usr/bin/env bash
# Resolve package install targets for local tools.

set -euo pipefail

THEMEMANAGER_RELEASE_VERSION="0.1.0"
THEMEMANAGER_RELEASE_TAG="v${THEMEMANAGER_RELEASE_VERSION}"

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

    error "Missing thememanager release checkout/tag. Expected ${HOME_DIR}/code/thememanager with tag ${THEMEMANAGER_RELEASE_TAG}, or set THEMEMANAGER_INSTALL_SPEC/THEMEMANAGER_SOURCE_DIR."
    return 1
}

resolve_thememanager_build_source() {
    local override="${THEMEMANAGER_SOURCE_DIR:-}"
    local standalone="${HOME_DIR}/code/thememanager"
    local build_dir

    if [[ -n "$override" ]]; then
        if [[ -f "${override}/pyproject.toml" ]]; then
            printf '%s\n' "$override"
            return 0
        fi

        error "THEMEMANAGER_SOURCE_DIR is not a thememanager package: ${override}"
        return 1
    fi

    if [[ -f "${standalone}/pyproject.toml" ]] &&
       git -C "$standalone" rev-parse -q --verify "refs/tags/${THEMEMANAGER_RELEASE_TAG}" >/dev/null 2>&1; then
        build_dir="$(mktemp -d)"
        git -C "$standalone" archive "${THEMEMANAGER_RELEASE_TAG}" | tar -x -C "$build_dir"
        printf '%s\n' "$build_dir"
        return 0
    fi

    error "Missing thememanager build source. Expected ${standalone} with tag ${THEMEMANAGER_RELEASE_TAG}, or set THEMEMANAGER_SOURCE_DIR."
    return 1
}

describe_thememanager_install_spec() {
    local install_spec="$1"

    if [[ "$install_spec" == git+file://*@${THEMEMANAGER_RELEASE_TAG} ]]; then
        printf 'release'
    elif [[ -f "${install_spec}/pyproject.toml" ]]; then
        printf 'source'
    else
        printf 'custom'
    fi
}

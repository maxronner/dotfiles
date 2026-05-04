#!/usr/bin/env bash
# Resolve package install targets for local tools.

set -euo pipefail

THEMEMANAGER_RELEASE_VERSION="0.1.0"
THEMEMANAGER_RELEASE_TAG="v${THEMEMANAGER_RELEASE_VERSION}"
THEMEMANAGER_RELEASE_REPO="git@codeberg.org:maxronner/thememanager.git"
THEMEMANAGER_RELEASE_SPEC="git+ssh://git@codeberg.org/maxronner/thememanager.git@${THEMEMANAGER_RELEASE_TAG}"

resolve_thememanager_release_spec() {
    printf '%s\n' "$THEMEMANAGER_RELEASE_SPEC"
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

    return 0
}

resolve_thememanager_build_source() {
    local override="${THEMEMANAGER_SOURCE_DIR:-}"
    local build_dir

    if [[ -n "$override" ]]; then
        if [[ -f "${override}/pyproject.toml" ]]; then
            printf '%s\n' "$override"
            return 0
        fi

        error "THEMEMANAGER_SOURCE_DIR is not a thememanager package: ${override}"
        return 1
    fi

    build_dir="$(mktemp -d)"
    if ! git clone --depth 1 --branch "$THEMEMANAGER_RELEASE_TAG" "$THEMEMANAGER_RELEASE_REPO" "$build_dir" >/dev/null; then
        rm -rf "$build_dir"
        return 1
    fi
    if [[ ! -f "${build_dir}/pyproject.toml" ]]; then
        error "Thememanager release checkout is not a Python package: ${build_dir}"
        rm -rf "$build_dir"
        return 1
    fi
    printf '%s\n' "$build_dir"
}

describe_thememanager_install_spec() {
    local install_spec="$1"

    if [[ "$install_spec" == "$THEMEMANAGER_RELEASE_SPEC" ]]; then
        printf 'release'
    elif [[ -f "${install_spec}/pyproject.toml" ]]; then
        printf 'source'
    else
        printf 'custom'
    fi
}

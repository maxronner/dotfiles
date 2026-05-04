#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
tmp_home="$(mktemp -d)"
export HOME="$tmp_home"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/tool-source.sh"

assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="$3"

    if [[ "$actual" != "$expected" ]]; then
        printf 'FAIL: %s\nexpected: %s\nactual:   %s\n' "$message" "$expected" "$actual" >&2
        exit 1
    fi
}

cleanup() {
    rm -rf "$tmp_home"
}
trap cleanup EXIT

mkdir -p "${tmp_home}/code/thememanager"
touch "${tmp_home}/code/thememanager/pyproject.toml"
git -C "${tmp_home}/code/thememanager" init -q
git -C "${tmp_home}/code/thememanager" config commit.gpgsign false
git -C "${tmp_home}/code/thememanager" config user.email "test@example.invalid"
git -C "${tmp_home}/code/thememanager" config user.name "Test User"
git -C "${tmp_home}/code/thememanager" add pyproject.toml
git -C "${tmp_home}/code/thememanager" commit -qm init
git -C "${tmp_home}/code/thememanager" tag v0.1.0

THEMEMANAGER_SOURCE_DIR=
assert_eq "$THEMEMANAGER_RELEASE_SPEC" "$(resolve_thememanager_install_spec)" "uses remote release spec"
assert_eq "release" "$(describe_thememanager_install_spec "$THEMEMANAGER_RELEASE_SPEC")" "describes release spec"

THEMEMANAGER_INSTALL_SPEC="git+https://example.invalid/thememanager@v0.1.0"
assert_eq "$THEMEMANAGER_INSTALL_SPEC" "$(resolve_thememanager_install_spec)" "uses explicit install spec"
assert_eq "custom" "$(describe_thememanager_install_spec "$THEMEMANAGER_INSTALL_SPEC")" "describes custom install spec"
unset THEMEMANAGER_INSTALL_SPEC

rm -rf "${tmp_home}/code/thememanager"
assert_eq "$THEMEMANAGER_RELEASE_SPEC" "$(resolve_thememanager_install_spec)" "remote release spec does not require local checkout"

override_dir="${tmp_home}/custom"
mkdir -p "$override_dir"
touch "${override_dir}/pyproject.toml"
THEMEMANAGER_SOURCE_DIR="$override_dir"
assert_eq "$override_dir" "$(resolve_thememanager_install_spec)" "uses explicit source override"
assert_eq "source" "$(describe_thememanager_install_spec "$override_dir")" "describes source override"

printf 'tool-source tests passed\n'

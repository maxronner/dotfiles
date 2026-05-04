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

THEMEMANAGER_SOURCE_DIR=
assert_eq "${tmp_home}/code/thememanager" "$(resolve_thememanager_source)" "prefers standalone checkout"
assert_eq "${tmp_home}/code/thememanager" "$(resolve_thememanager_standalone_source)" "resolves standalone checkout"
assert_eq "standalone" "$(describe_thememanager_source "${tmp_home}/code/thememanager")" "describes standalone checkout"

rm -rf "${tmp_home}/code/thememanager"
assert_eq "${DOTS_DIR}/tools/thememanager" "$(resolve_thememanager_source)" "falls back to bundled source"
assert_eq "bundled" "$(describe_thememanager_source "${DOTS_DIR}/tools/thememanager")" "describes bundled source"

override_dir="${tmp_home}/custom"
mkdir -p "$override_dir"
touch "${override_dir}/pyproject.toml"
THEMEMANAGER_SOURCE_DIR="$override_dir"
assert_eq "$override_dir" "$(resolve_thememanager_source)" "uses explicit override"
assert_eq "$override_dir" "$(resolve_thememanager_standalone_source)" "uses explicit override for standalone source"
assert_eq "custom" "$(describe_thememanager_source "$override_dir")" "describes custom override"

printf 'tool-source tests passed\n'

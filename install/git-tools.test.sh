#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"
source "${SCRIPT_DIR}/git-tools.sh"

TEST_ROOTS=()

cleanup() {
    local root
    for root in "${TEST_ROOTS[@]}"; do
        rm -rf "$root"
    done
}
trap cleanup EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

make_root() {
    local root
    root="$(mktemp -d)"
    TEST_ROOTS+=("$root")
    printf '%s\n' "$root"
}

make_repo() {
    local repo="$1"
    mkdir -p "$repo"
    git -C "$repo" init -q
    printf 'demo\n' > "${repo}/README.md"
    git -C "$repo" add README.md
    git -C "$repo" \
        -c user.name='Dots Test' \
        -c user.email='dots@example.invalid' \
        -c commit.gpgsign=false \
        commit -qm 'init'
}

commit_file() {
    local repo="$1"
    local path="$2"
    local content="$3"
    local message="$4"

    printf '%s\n' "$content" > "${repo}/${path}"
    git -C "$repo" add "$path"
    git -C "$repo" \
        -c user.name='Dots Test' \
        -c user.email='dots@example.invalid' \
        -c commit.gpgsign=false \
        commit -qm "$message"
}

test_installs_manifest_entry() {
    local root repo manifest marker
    root="$(make_root)"
    repo="${root}/repo"
    manifest="${root}/tools.txt"
    marker="${root}/installed"

    make_repo "$repo"
    printf 'demo|demo-tool|%s|-|printf installed > "$GIT_TOOL_TEST_MARKER"\n' "$repo" > "$manifest"

    DOTS_GIT_TOOLS_DIR="${root}/sources" GIT_TOOL_TEST_MARKER="$marker" install_git_tool_manifest "$manifest"

    [[ "$(cat "$marker")" == "installed" ]] || fail "expected install command to run"
    [[ -d "${root}/sources/demo/.git" ]] || fail "expected stable source checkout"
}

test_updates_existing_checkout() {
    local root repo manifest marker
    root="$(make_root)"
    repo="${root}/repo"
    manifest="${root}/tools.txt"
    marker="${root}/installed"

    make_repo "$repo"
    printf 'demo|demo-tool|%s|-|cat README.md > "$GIT_TOOL_TEST_MARKER"\n' "$repo" > "$manifest"

    DOTS_GIT_TOOLS_DIR="${root}/sources" GIT_TOOL_TEST_MARKER="$marker" install_git_tool_manifest "$manifest"
    [[ "$(cat "$marker")" == "demo" ]] || fail "expected initial install content"

    commit_file "$repo" README.md updated update
    DOTS_GIT_TOOLS_DIR="${root}/sources" GIT_TOOL_TEST_MARKER="$marker" install_git_tool_manifest "$manifest"

    [[ "$(cat "$marker")" == "updated" ]] || fail "expected updated install content"
}

test_rejects_invalid_entry() {
    local root manifest status
    root="$(make_root)"
    manifest="${root}/tools.txt"
    printf 'broken|entry\n' > "$manifest"

    set +e
    install_git_tool_manifest "$manifest" >/dev/null 2>&1
    status="$?"
    set -e

    [[ "$status" != "0" ]] || fail "expected invalid manifest to fail"
}

test_failed_clone_does_not_run_install_command() {
    local root manifest marker
    root="$(make_root)"
    manifest="${root}/tools.txt"
    marker="${root}/installed"

    printf 'missing|missing-tool|%s|-|printf bad > "%s"\n' "${root}/missing-repo" "$marker" > "$manifest"

    DOTS_GIT_TOOLS_DIR="${root}/sources" install_git_tool_manifest "$manifest" >/dev/null 2>&1

    [[ ! -e "$marker" ]] || fail "install command ran after clone failure"
}

test_installed_command_still_runs_install_command() {
    local root repo manifest marker
    root="$(make_root)"
    repo="${root}/repo"
    manifest="${root}/tools.txt"
    marker="${root}/installed"

    make_repo "$repo"
    mkdir -p "${root}/bin"
    printf '#!/usr/bin/env bash\n' > "${root}/bin/demo-tool"
    chmod +x "${root}/bin/demo-tool"
    printf 'installer|demo-tool|%s|-|printf run >> "%s"\n' "$repo" "$marker" > "$manifest"

    DOTS_GIT_TOOLS_DIR="${root}/sources" PATH="${root}/bin:${PATH}" install_git_tool_manifest "$manifest"

    [[ "$(cat "$marker")" == "run" ]] || fail "expected installed command to still run install"
}

main() {
    test_installs_manifest_entry
    test_updates_existing_checkout
    test_rejects_invalid_entry
    test_failed_clone_does_not_run_install_command
    test_installed_command_still_runs_install_command
    printf 'git-tools tests passed\n'
}

main "$@"

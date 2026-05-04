#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DISPATCH="${SCRIPT_DIR}/dispatch-packaged-tool"
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
  mkdir -p "$root/bin" "$root/repo"
  printf '%s\n' "$root"
}

write_executable() {
  local path="$1"
  local body="$2"
  printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' "$body" > "$path"
  chmod +x "$path"
}

test_prefers_installed_command() {
  local root output
  root="$(make_root)"
  write_executable "$root/bin/demo" 'printf "installed:%s\n" "$*"'
  write_executable "$root/repo/fallback" 'printf "fallback:%s\n" "$*"'

  output="$(PATH="$root/bin:$PATH" "$DISPATCH" demo "$root/repo/fallback" -- one two)"
  [[ "$output" == "installed:one two" ]] || fail "expected installed command, got: $output"
}

test_falls_back_when_missing() {
  local root output
  root="$(make_root)"
  write_executable "$root/repo/fallback" 'printf "fallback:%s\n" "$*"'

  output="$(PATH="$root/bin:$PATH" "$DISPATCH" demo "$root/repo/fallback" -- one)"
  [[ "$output" == "fallback:one" ]] || fail "expected fallback, got: $output"
}

test_skips_caller_to_avoid_recursion() {
  local root output
  root="$(make_root)"
  write_executable "$root/bin/demo" "exec \"\$DISPATCH\" demo \"$root/repo/fallback\" -- \"\$@\""
  write_executable "$root/repo/fallback" 'printf "fallback:%s\n" "$*"'

  output="$(DISPATCH="$DISPATCH" DISPATCH_PACKAGED_TOOL_CALLER="$root/bin/demo" PATH="$root/bin:$PATH" "$root/bin/demo" one)"
  [[ "$output" == "fallback:one" ]] || fail "expected recursion skip fallback, got: $output"
}

main() {
  test_prefers_installed_command
  test_falls_back_when_missing
  test_skips_caller_to_avoid_recursion
  printf 'dispatch-packaged-tool tests passed\n'
}

main "$@"

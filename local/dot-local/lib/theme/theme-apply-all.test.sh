#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
THEME_APPLY_ALL="${SCRIPT_DIR}/../../bin/theme-apply-all"
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

assert_contains() {
  local haystack=$1
  local needle=$2
  [[ $haystack == *"$needle"* ]] || fail "expected to find '$needle' in: $haystack"
}

assert_not_contains() {
  local haystack=$1
  local needle=$2
  [[ $haystack != *"$needle"* ]] || fail "did not expect to find '$needle' in: $haystack"
}

make_adapter() {
  local root=$1
  local app=$2
  local mode=${3:-ok}
  local script="$root/config/$app/scripts/apply-theme"
  mkdir -p "$(dirname "$script")"
  cat > "$script" <<EOF
#!/usr/bin/env bash
set -euo pipefail
printf '%s %s\n' '$app' "\${1:-apply}" >> "\$THEME_TEST_LOG"
if [[ '$mode' == fail ]]; then
  echo '$app failed' >&2
  exit 7
fi
EOF
  chmod +x "$script"
}

make_test_root() {
  local root
  root=$(mktemp -d)
  TEST_ROOTS+=("$root")
  mkdir -p "$root/data/theme" "$root/runtime" "$root/config"
  printf '{"version":2}\n' > "$root/data/theme/palette.json"
  printf '%s\n' "$root"
}

run_theme_apply_all() {
  local root=$1
  shift
  env \
    XDG_CONFIG_HOME="$root/config" \
    XDG_DATA_HOME="$root/data" \
    XDG_RUNTIME_DIR="$root/runtime" \
    THEME_TEST_LOG="$root/log" \
    "$THEME_APPLY_ALL" "$@"
}

test_applies_adapters_in_deterministic_order() {
  local root
  root=$(make_test_root)

  make_adapter "$root" zed
  make_adapter "$root" alpha
  make_adapter "$root" mid

  run_theme_apply_all "$root" 2> "$root/stderr"

  local log
  log=$(cat "$root/log")
  [[ $log == $'alpha apply\nmid apply\nzed apply' ]] || fail "unexpected adapter order: $log"

  local stderr
  stderr=$(cat "$root/stderr")
  assert_contains "$stderr" "theme-apply-all: applied=3 failed=0"
}

test_check_forwards_check_arg() {
  local root
  root=$(make_test_root)

  make_adapter "$root" app
  run_theme_apply_all "$root" --check 2> "$root/stderr"

  local log
  log=$(cat "$root/log")
  [[ $log == "app --check" ]] || fail "expected --check forwarding, got: $log"
}

test_missing_palette_skips_adapters() {
  local root
  root=$(make_test_root)

  rm "$root/data/theme/palette.json"
  make_adapter "$root" app
  run_theme_apply_all "$root" 2> "$root/stderr"

  [[ ! -f "$root/log" ]] || fail "adapter ran despite missing palette"
  assert_contains "$(cat "$root/stderr")" "no palette"
}

test_adapter_failure_is_reported() {
  local root
  root=$(make_test_root)

  make_adapter "$root" ok
  make_adapter "$root" bad fail

  if run_theme_apply_all "$root" 2> "$root/stderr"; then
    fail "expected failure when an adapter fails"
  fi

  local stderr
  stderr=$(cat "$root/stderr")
  assert_contains "$stderr" "theme-apply-all: FAIL bad"
  assert_contains "$stderr" "theme-apply-all: applied=1 failed=1"
}

main() {
  test_applies_adapters_in_deterministic_order
  test_check_forwards_check_arg
  test_missing_palette_skips_adapters
  test_adapter_failure_is_reported
  printf 'theme-apply-all tests passed\n'
}

main "$@"

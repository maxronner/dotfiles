#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/scratch"

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

make_fake_tmux_bin() {
	local fakebin
	fakebin=$(mktemp -d)

	cat >"$fakebin/tmux" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

log_call() {
  local line
  printf -v line '%q ' "$@"
  printf '%s\n' "${line% }" >>"$FAKE_TMUX_LOG"
}

log_call "$@"

case "${1-}" in
display)
  if [[ ${2-} == "-p" && ${3-} == "#S" ]]; then
    printf 'sess\n'
  elif [[ ${2-} == "-p" && ${3-} == "#I" ]]; then
    printf '1\n'
  elif [[ ${2-} == "-p" && ${3-} == "-F" && ${4-} == '#{pane_current_path}' ]]; then
    printf '/tmp\n'
  else
    printf 'unsupported display invocation\n' >&2
    exit 98
  fi
  ;;
list-panes)
  if [[ ${2-} == "-a" ]]; then
    case "${FAKE_TMUX_SCENARIO:-create}" in
    move)
      printf 'sess:2.1 __scratch__ 1\n'
      ;;
    *) ;;
    esac
  else
    printf '0\n'
  fi
  ;;
list-windows)
  printf '0\n2\n'
  ;;
split-window)
  printf '%%42\n'
  ;;
set-option | select-pane | select-window | move-pane | break-pane | new-window)
  ;;
*)
  printf 'unsupported tmux invocation: %s\n' "$*" >&2
  exit 99
  ;;
esac
EOF

	chmod +x "$fakebin/tmux"
	printf '%s\n' "$fakebin"
}

run_with_fake_tmux() {
	local scenario=$1
	shift

	local fakebin logfile
	fakebin=$(make_fake_tmux_bin)
	logfile=$(mktemp)

	PATH="$fakebin:$PATH" FAKE_TMUX_LOG="$logfile" FAKE_TMUX_SCENARIO="$scenario" "$SCRIPT" "$@"

	cat "$logfile"
}

test_usage_mentions_size() {
	local output
	output=$("$SCRIPT" --help)
	assert_contains "$output" "--size SIZE"
	assert_not_contains "$output" "--small"
}

test_missing_size_arg_exits_with_message() {
	local output status

	set +e
	output=$("$SCRIPT" --size 2>&1)
	status=$?
	set -e

	[[ $status -eq 1 ]] || fail "expected --size without argument to exit 1, got $status"
	assert_contains "$output" "missing argument for --size"
}

test_option_like_size_arg_exits_with_message() {
	local output status

	set +e
	output=$("$SCRIPT" --size -- 2>&1)
	status=$?
	set -e

	[[ $status -eq 1 ]] || fail "expected --size -- to exit 1, got $status"
	assert_contains "$output" "missing argument for --size"
}

test_command_creation_defaults_to_50_percent() {
	local log
	log=$(run_with_fake_tmux create -- printf hi)

	assert_contains "$log" "split-window"
	assert_contains "$log" "-l 50%"
}

test_explicit_size_overrides_command_default() {
	local log
	log=$(run_with_fake_tmux create --size 37% -- printf hi)

	assert_contains "$log" "split-window"
	assert_contains "$log" "-l 37%"
	assert_not_contains "$log" "-l 50%"
}

test_small_alias_is_rejected() {
	local output status

	set +e
	output=$("$SCRIPT" -s 2>&1)
	status=$?
	set -e

	[[ $status -eq 1 ]] || fail "expected -s to exit 1, got $status"
	assert_contains "$output" "unknown option: -s"
}

test_explicit_size_is_shared_with_move_pane_args() {
	local log
	log=$(run_with_fake_tmux move --size 41%)

	assert_contains "$log" "move-pane"
	assert_contains "$log" "-l 41%"
}

main() {
	test_usage_mentions_size
	test_missing_size_arg_exits_with_message
	test_option_like_size_arg_exits_with_message
	test_command_creation_defaults_to_50_percent
	test_explicit_size_overrides_command_default
	test_small_alias_is_rejected
	test_explicit_size_is_shared_with_move_pane_args
	printf 'scratch tests passed\n'
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/scratch"
LIB="$SCRIPT_DIR/lib/tmux-marker.sh"
TEST_LIB="$SCRIPT_DIR/lib/tmux-test.sh"

# shellcheck source=lib/tmux-test.sh
source "$TEST_LIB"

run_lib_with_fake_tmux() {
	run_shell_with_fake_tmux create "source \"$LIB\"; tmux_marker_set_pane '%42' scratch name '__scratch__'"
}

test_usage_mentions_size() {
	local output
	output=$("$SCRIPT" --help)
	assert_contains "$output" "--size SIZE"
	assert_not_contains "$output" "--small"
	assert_not_contains "$output" "--window"
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

test_marker_lib_builds_tmux_option_names() {
	local option format

	# shellcheck source=lib/tmux-marker.sh
	source "$LIB"
	option=$(tmux_marker_option scratch name)
	format=$(tmux_marker_format scratch origin)

	[[ $option == "@scratch_name" ]] || fail "expected marker option name, got: $option"
	[[ $format == "#{@scratch_origin}" ]] || fail "expected marker format, got: $format"
}

test_marker_lib_sets_pane_marker_option() {
	local log
	log=$(run_lib_with_fake_tmux)

	assert_contains "$log" "set-option -pt %42 @scratch_name __scratch__"
}

test_command_creation_defaults_to_50_percent() {
	local log
	log=$(run_with_fake_tmux create "$SCRIPT" -- printf hi)

	assert_contains "$log" "split-window"
	assert_contains "$log" "-l 50%"
}

test_explicit_size_overrides_command_default() {
	local log
	log=$(run_with_fake_tmux create "$SCRIPT" --size 37% -- printf hi)

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

test_window_alias_is_rejected() {
	local output status

	set +e
	output=$("$SCRIPT" -w 2>&1)
	status=$?
	set -e

	[[ $status -eq 1 ]] || fail "expected -w to exit 1, got $status"
	assert_contains "$output" "unknown option: -w"
}

test_explicit_size_is_shared_with_move_pane_args() {
	local log
	log=$(run_with_fake_tmux move "$SCRIPT" --size 41%)

	assert_contains "$log" "move-pane"
	assert_contains "$log" "-l 41%"
}

main() {
	test_usage_mentions_size
	test_missing_size_arg_exits_with_message
	test_option_like_size_arg_exits_with_message
	test_marker_lib_builds_tmux_option_names
	test_marker_lib_sets_pane_marker_option
	test_command_creation_defaults_to_50_percent
	test_explicit_size_overrides_command_default
	test_small_alias_is_rejected
	test_window_alias_is_rejected
	test_explicit_size_is_shared_with_move_pane_args
	printf 'scratch tests passed\n'
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/bullseye"
TEST_LIB="$SCRIPT_DIR/lib/tmux-test.sh"

# shellcheck source=lib/tmux-test.sh
source "$TEST_LIB"

test_usage_mentions_marker() {
	local output
	output=$("$SCRIPT" --help)
	assert_contains "$output" "--marker MARKER"
}

test_missing_command_exits_with_message() {
	local output status

	set +e
	output=$("$SCRIPT" 2>&1)
	status=$?
	set -e

	[[ $status -eq 1 ]] || fail "expected missing command to exit 1, got $status"
	assert_contains "$output" "missing command"
}

test_creates_window_named_after_command_by_default() {
	local log
	log=$(run_with_fake_tmux create "$SCRIPT" -- printf hi)

	assert_contains "$log" "select-window -t sess:printf"
	assert_contains "$log" "new-window -n printf -c /tmp printf hi"
}

test_marker_overrides_default_window_name() {
	local log
	log=$(run_with_fake_tmux create "$SCRIPT" -m ai -- printf hi)

	assert_contains "$log" "select-window -t sess:ai"
	assert_contains "$log" "new-window -n ai -c /tmp printf hi"
}

test_selects_existing_window_without_creating() {
	local log
	log=$(run_with_fake_tmux existing "$SCRIPT" -m ai -- printf hi)

	assert_contains "$log" "select-window -t sess:ai"
	[[ $log != *"new-window"* ]] || fail "did not expect new-window when select-window succeeds"
}

main() {
	test_usage_mentions_marker
	test_missing_command_exits_with_message
	test_creates_window_named_after_command_by_default
	test_marker_overrides_default_window_name
	test_selects_existing_window_without_creating
	printf 'bullseye tests passed\n'
}

main "$@"

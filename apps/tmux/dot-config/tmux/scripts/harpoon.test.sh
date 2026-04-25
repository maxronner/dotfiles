#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$SCRIPT_DIR/harpoon"
TEST_LIB="$SCRIPT_DIR/lib/tmux-test.sh"

# shellcheck source=lib/tmux-test.sh
source "$TEST_LIB"

make_temp_home() {
	local temp_home
	temp_home=$(mktemp -d)
	mkdir -p "$temp_home/.local/state"
	printf '%s\n' "$temp_home"
}

test_missing_command_exits_with_usage() {
	local temp_home output status
	temp_home=$(make_temp_home)

	set +e
	output=$(HOME="$temp_home" "$SCRIPT" 2>&1)
	status=$?
	set -e

	[[ $status -eq 1 ]] || fail "expected missing command to exit 1, got $status"
	assert_contains "$output" "usage: harpoon"
}

test_edit_opens_editor_in_popup() {
	local state_home log expected_command
	state_home=$(mktemp -d)
	log=$(
		export XDG_STATE_HOME="$state_home"
		run_with_fake_tmux create "$SCRIPT" edit
	)
	expected_command=$(printf '%q' "$(printf '%q %q' nvim "$state_home/tmux-harpoon")")

	assert_contains "$log" "display-popup -w 80% -h 80% -E $expected_command"
}

test_add_appends_session_name_only() {
	local state_home state_file
	state_home=$(mktemp -d)
	state_file="$state_home/tmux-harpoon"

	(
		export XDG_STATE_HOME="$state_home" FAKE_TMUX_SESSION="alpha"
		run_with_fake_tmux create "$SCRIPT" add >/dev/null
	)
	(
		export XDG_STATE_HOME="$state_home" FAKE_TMUX_SESSION="beta"
		run_with_fake_tmux create "$SCRIPT" add >/dev/null
	)

	[[ $(<"$state_file") == $'alpha\nbeta' ]] || fail "expected session-only state file, got: $(<"$state_file")"
}

test_jump_uses_line_number_and_normalizes_legacy_entries() {
	local state_home log
	state_home=$(mktemp -d)
	printf '1 alpha\n2 beta\n' >"$state_home/tmux-harpoon"

	log=$(
		export XDG_STATE_HOME="$state_home"
		run_with_fake_tmux create "$SCRIPT" jump 2
	)

	assert_contains "$log" "switch-client -t beta"
	[[ $(<"$state_home/tmux-harpoon") == $'alpha\nbeta' ]] || fail "expected legacy state to normalize, got: $(<"$state_home/tmux-harpoon")"
}

test_add_moves_existing_session_to_end() {
	local state_home state_file
	state_home=$(mktemp -d)
	state_file="$state_home/tmux-harpoon"
	printf 'alpha\nbeta\n' >"$state_file"

	(
		export XDG_STATE_HOME="$state_home" FAKE_TMUX_SESSION="alpha"
		run_with_fake_tmux create "$SCRIPT" add >/dev/null
	)

	[[ $(<"$state_file") == $'beta\nalpha' ]] || fail "expected append-to-end behavior, got: $(<"$state_file")"
}

main() {
	test_missing_command_exits_with_usage
	test_edit_opens_editor_in_popup
	test_add_appends_session_name_only
	test_jump_uses_line_number_and_normalizes_legacy_entries
	test_add_moves_existing_session_to_end
	printf 'harpoon tests passed\n'
}

main "$@"

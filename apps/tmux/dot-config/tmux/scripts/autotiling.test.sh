#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
LIB="$SCRIPT_DIR/lib/autotiling.sh"

# shellcheck source=lib/autotiling.sh
source "$LIB"

fail() {
	printf 'FAIL: %s\n' "$*" >&2
	exit 1
}

test_wide_panes_split_left_right() {
	local flag
	flag=$(tmux_autotile_split_flag_for_size 200 80 10 21)
	[[ $flag == '-h' ]] || fail "expected -h for wide pane, got: $flag"
}

test_tall_panes_split_top_bottom() {
	local flag
	flag=$(tmux_autotile_split_flag_for_size 80 200 10 21)
	[[ $flag == '-v' ]] || fail "expected -v for tall pane, got: $flag"
}

test_square_cells_can_still_be_tall_on_screen() {
	local flag
	flag=$(tmux_autotile_split_flag_for_size 100 100 10 21)
	[[ $flag == '-v' ]] || fail "expected -v for visually tall square-cell pane, got: $flag"
}

test_square_cells_prefer_left_right_with_square_pixels() {
	local flag
	flag=$(tmux_autotile_split_flag_for_size 100 100 1 1)
	[[ $flag == '-h' ]] || fail "expected -h for square-pixel pane, got: $flag"
}

main() {
	test_wide_panes_split_left_right
	test_tall_panes_split_top_bottom
	test_square_cells_can_still_be_tall_on_screen
	test_square_cells_prefer_left_right_with_square_pixels
	printf 'autotiling tests passed\n'
}

main "$@"

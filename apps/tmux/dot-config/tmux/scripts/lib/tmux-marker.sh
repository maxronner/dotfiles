#!/usr/bin/env bash

tmux_marker_option() {
	printf '@%s_%s' "$1" "$2"
}

tmux_marker_format() {
	printf '#{%s}' "$(tmux_marker_option "$1" "$2")"
}

tmux_marker_set_pane() {
	tmux set-option -pt "$1" "$(tmux_marker_option "$2" "$3")" "$4"
}

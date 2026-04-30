#!/usr/bin/env bash

tmux_autotile_split_flag_for_size() {
	local pane_width=${1:?pane width is required}
	local pane_height=${2:?pane height is required}
	local cell_width=${3:?cell width is required}
	local cell_height=${4:?cell height is required}
	local screen_width screen_height

	screen_width=$((pane_width * cell_width))
	screen_height=$((pane_height * cell_height))

	if ((screen_width >= screen_height)); then
		printf '%s\n' '-h'
		return
	fi

	printf '%s\n' '-v'
}

tmux_autotile_split_flag() {
	local pane_id=${1:?pane id is required}
	local pane_width pane_height cell_width cell_height

	pane_width=$(tmux display-message -p -t "$pane_id" '#{pane_width}')
	pane_height=$(tmux display-message -p -t "$pane_id" '#{pane_height}')
	cell_width=$(tmux display-message -p '#{client_cell_width}')
	cell_height=$(tmux display-message -p '#{client_cell_height}')

	tmux_autotile_split_flag_for_size "$pane_width" "$pane_height" "$cell_width" "$cell_height"
}

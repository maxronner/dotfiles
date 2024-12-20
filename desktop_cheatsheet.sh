#!/bin/bash

# Session and Window Name
SESSION="cheatsheet"

tmux has-session -t "$SESSION" 2>/dev/null

# Check if tmux session does not exist
if [ $? != 0 ];  then
    # Create a new tmux session and window
    tmux new-session -d -s "$SESSION" -n "$SESSION"
    tmux send-keys -t $SESSION "curl cheat.sh/vim" C-m

    # Split the pane vertically
    tmux split-window -v
    tmux send-keys -t $SESSION "grep bindsym ~/.config/sway/config | sed 's/^[[:space:]]*bindsym //' | column -tl 2" C-m

    tmux split-window -h
    tmux send-keys -t $SESSION "curl cheat.sh/tmux" C-m
fi

# Attach to the session
tmux attach-session -t "$SESSION"

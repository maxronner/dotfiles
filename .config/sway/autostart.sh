#!/bin/bash

# Session and Window Name
SESSION_NAME="sway-default"

# Check if tmux session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# Create a new tmux session and window
tmux new-session -d -s "$SESSION_NAME"

# Split the pane vertically
tmux split-window -v

# Attach to the session
tmux attach-session -t "$SESSION_NAME"

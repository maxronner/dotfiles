#!/bin/bash

if tmux list-windows -F '#W' | grep -Fxq yazi; then
    tmux select-window -t yazi
else
    tmux new-window -n yazi yazi
fi


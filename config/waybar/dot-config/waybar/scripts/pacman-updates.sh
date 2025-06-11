#!/bin/bash

updates_output=$(checkupdates)
status=$?

if [ "$status" -eq 0 ]; then
    # Updates are available; count and print the lines
    echo "$updates_output" | wc -l
elif [ "$status" -eq 1 ]; then
    # No updates are available
    echo "0"
else # status is 2 or other error
    # An error occurred (e.g., database locked)
    echo "?"
fi

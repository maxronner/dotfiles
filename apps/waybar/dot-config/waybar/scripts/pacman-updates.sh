#!/bin/bash

updates_output=$(checkupdates)
status=$?

if [ "$status" -eq 0 ]; then
    echo "$updates_output" | wc -l
else
    echo "0"
fi

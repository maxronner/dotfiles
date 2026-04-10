#!/bin/bash

if ! pgrep -x gammastep > /dev/null; then
    printf '{"text": "off", "alt": "off"}'
    exit 0
fi

for PID in $(pidof gammastep); do
    cmdline=$(ps -p "$PID" -o args=)
    if [[ $cmdline =~ -O[[:space:]]*([0-9]+) ]]; then
        printf '{"text": "%sK", "alt": "on"}' "${BASH_REMATCH[1]}"
        exit 0
    fi
done

printf '{"text": "auto", "alt": "auto"}'

#!/bin/bash

set -euo pipefail

PREFIX="${PREFIX:-$HOME/.password-store}"

candidates() {
    find "$PREFIX" -name '*.gpg' \
        | sed -e "s:$PREFIX/::gi" -e 's:.gpg$::gi'
}

candidate_selector_fzf() {
    local query=$1
    candidates | fzf -q "$query" --select-1
}

usage() {
    echo "Usage: $0 [-s] [-c] [query]"
    echo
    echo "  -s   only select and print the entry name"
    echo "  -c   copy OTP to clipboard instead of showing"
    exit 1
}

select_only=0
copy=0

while getopts "sc" o; do
    case "${o}" in
        s) select_only=1 ;;
        c) copy=1 ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))

query="$*"
res=$(candidate_selector_fzf "$query")

if [ -n "$res" ]; then
    if [ $select_only -ne 0 ]; then
        echo "$res"
        exit 0
    fi
    if [ $copy -ne 0 ]; then
        pass otp -c "$res"
    else
        pass otp "$res"
    fi
else
    exit 1
fi

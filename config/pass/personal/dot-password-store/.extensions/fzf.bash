#!/bin/bash

function candidates() {
    find "$PREFIX" -name '*.gpg' | sed -e "s:$PREFIX/::gi" -e 's:.gpg$::gi'
}

function candidate_selector_fzf() {
    query=$1
    candidates | fzf -q "$query" --select-1
}

function usage() {
    echo "Usage: $0 [-s] [-a] [query]"
    echo "  -s    Select only (print entry name)"
    echo "  -a    Show full entry (no clipboard copy)"
    exit 1
}

select_only=0
show_all=0

while getopts "sa" o; do
    case "${o}" in
        s)
            select_only=1
            ;;
        a)
            show_all=1
            ;;
        *)
            usage
            ;;
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

    if [ $show_all -ne 0 ]; then
        # Show full entry, do not copy to clipboard
        pass show "$res" || exit $?
    else
        # Original behavior: skip first line and copy password to clipboard
        pass show "$res" | tail -n +2 || exit $?
        pass show -c "$res"
    fi
else
    exit 1
fi


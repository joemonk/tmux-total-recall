#!/usr/bin/env bash
# Delete an entry - either from file or tmux buffer
REF="$1"

if echo "$REF" | grep -q '^buf:'; then
    bufname=$(echo "$REF" | sed 's/^buf://')
    tmux delete-buffer -b "$bufname"
else
    filepath=$(echo "$REF" | sed 's/:[0-9]*$//')
    linenum=$(echo "$REF" | grep -oE '[0-9]+$')
    [ -f "$filepath" ] || exit 0
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "${linenum}d" "$filepath"
    else
        sed -i '' "${linenum}d" "$filepath"
    fi
fi

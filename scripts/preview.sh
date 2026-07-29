#!/usr/bin/env bash
# Preview what will be pasted
REF="$1"
DELIMITER="${2:- ::=:: }"

if echo "$REF" | grep -q '^buf:'; then
    bufname=$(echo "$REF" | sed 's/^buf://')
    tmux show-buffer -b "$bufname" 2>/dev/null
else
    filepath=$(echo "$REF" | sed 's/:[0-9]*$//')
    linenum=$(echo "$REF" | grep -oE '[0-9]+$')
    sed -n "${linenum}p" "$filepath" 2>/dev/null | awk -v delim="$DELIMITER" '{
        pos = index($0, delim)
        if (pos > 0) { print substr($0, 1, pos - 1) }
        else { print $0 }
    }'
fi

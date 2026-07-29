#!/usr/bin/env bash
# Preview what will be pasted for a given buffer name
BUF_NAME="$1"
DELIMITER="${2:- ::=:: }"

tmux show-buffer -b "$BUF_NAME" 2>/dev/null | awk -v delim="$DELIMITER" '{
    pos = index($0, delim)
    if (pos > 0) {
        print substr($0, 1, pos - 1)
    } else {
        print $0
    }
}'

#!/usr/bin/env bash
# Preview what will be pasted
BUF_NAME="$1"
DELIMITER="${2:- ::=:: }"

content=$(tmux show-buffer -b "$BUF_NAME" 2>/dev/null)
if echo "$content" | grep -qF "$DELIMITER"; then
    echo "$content" | sed "s/$(printf '%s' "$DELIMITER" | sed 's/[[\.*^$()+?{}|]/\\&/g').*//"
else
    echo "$content"
fi

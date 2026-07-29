#!/usr/bin/env bash
# List all buffers with display labels
DELIMITER="${1:- ::=:: }"

tmux list-buffers -F '#{buffer_name}' | while read -r name; do
    content=$(tmux show-buffer -b "$name" 2>/dev/null)
    label=$(printf '%s' "$content" | awk -v delim="$DELIMITER" '{
        pos = index($0, delim)
        if (pos > 0) { s = substr($0, pos + length(delim)); print s }
        else { print $0 }
    }')
    echo "$name: $label"
done | awk -F': ' '!seen[$2]++'

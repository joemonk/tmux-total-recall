#!/usr/bin/env bash
# List all buffers with display labels
DELIMITER="${1:- ::=:: }"

SEEN=$(mktemp)
trap 'rm -f "$SEEN"' EXIT

tmux list-buffers -F '#{buffer_name}' | while read -r name; do
    content=$(tmux show-buffer -b "$name" 2>/dev/null)
    if echo "$content" | grep -qF "$DELIMITER"; then
        label=$(echo "$content" | sed "s/.*$(printf '%s' "$DELIMITER" | sed 's/[[\.*^$()+?{}|]/\\&/g')//")
    else
        label="$content"
    fi
    grep -qxF "$label" "$SEEN" && continue
    echo "$label" >> "$SEEN"
    echo "$name: $label"
done

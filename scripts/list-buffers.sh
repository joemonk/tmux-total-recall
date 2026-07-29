#!/usr/bin/env bash
# List all buffers with display labels for fzf reload
tmux list-buffers -F '#{buffer_name}' | while read -r name; do
    content=$(tmux show-buffer -b "$name" 2>/dev/null)
    label=$(printf '%s' "$content" | awk '{
        pos = index($0, " = \"")
        if (pos > 0 && substr($0, length($0)) == "\"") {
            s = substr($0, pos + 4)
            sub(/"$/, "", s)
            print s
        } else {
            print $0
        }
    }')
    echo "$name: $label"
done | awk -F': ' '!seen[$2]++'

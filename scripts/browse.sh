#!/usr/bin/env bash
# Browse tmux buffers with fzf, paste selected (key only if key="label" format)
KEY_PATTERN="${1:-^[^ ]+ = \".*\"\$}"

selected=$(
    tmux list-buffers -F '#{buffer_name}' | while read -r name; do
        content=$(tmux show-buffer -b "$name" 2>/dev/null)
        label=$(echo "$content" | awk -v pat="$KEY_PATTERN" '$0 ~ pat {match($0, /"(.*)"/,a); print a[1]; exit} {print}')
        echo "$name: $label"
    done \
    | awk '!seen[$2]++' \
    | fzf --with-nth 2.. \
          --delimiter ': ' \
          --header '' \
          --preview "tmux show-buffer -b {1} | awk -v pat='$KEY_PATTERN' '\$0 ~ pat {print \$1; exit} {print}'" \
          --preview-window right:40%
)

[ -z "$selected" ] && exit 0

buf_name=$(echo "$selected" | sed 's/: .*//')
tmux show-buffer -b "$buf_name" \
    | awk -v pat="$KEY_PATTERN" '$0 ~ pat {print $1; exit} {print}' \
    | tr -d '\n' \
    | tmux load-buffer -
tmux paste-buffer

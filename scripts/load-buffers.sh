#!/usr/bin/env bash
# Load each line of a file as a separate tmux buffer
file="$1"
[ -z "$file" ] && exit 1
[ -f "$file" ] || exit 0
while IFS= read -r line; do
    [ -n "$line" ] && printf '%s' "$line" | tmux load-buffer -
done < "$file"

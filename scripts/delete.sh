#!/usr/bin/env bash
# Delete a buffer from tmux and remove from cache/source files
BUF_NAME="$1"
CACHE_FILE="$2"
SOURCES="$3"

content=$(tmux show-buffer -b "$BUF_NAME" 2>/dev/null)
[ -z "$content" ] && exit 0

tmux delete-buffer -b "$BUF_NAME"

for f in "$CACHE_FILE" $SOURCES; do
    [ -f "$f" ] || continue
    grep -qF "$content" "$f" && grep -vF "$content" "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

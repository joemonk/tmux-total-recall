#!/usr/bin/env bash
# Browse tmux buffers with fzf, paste selected
CACHE_FILE="${1:-}"
SOURCES="${2:-}"
DELIMITER="${3:- ::=:: }"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

selected=$(
    "$SCRIPT_DIR/list-buffers.sh" "$DELIMITER" \
    | fzf --with-nth 2.. \
          --delimiter ': ' \
          --header 'enter: paste  ctrl-d: delete' \
          --preview "$SCRIPT_DIR/preview.sh {1} '$DELIMITER'" \
          --preview-window right:40% \
          --bind "ctrl-d:execute($SCRIPT_DIR/delete.sh {1} '$CACHE_FILE' '$SOURCES')+reload($SCRIPT_DIR/list-buffers.sh '$DELIMITER')"
)

[ -z "$selected" ] && exit 0

buf_name=$(echo "$selected" | sed 's/: .*//')
content=$(tmux show-buffer -b "$buf_name")

if echo "$content" | grep -qF "$DELIMITER"; then
    paste=$(echo "$content" | sed "s/$(printf '%s' "$DELIMITER" | sed 's/[[\.*^$()+?{}|]/\\&/g').*//" | tr -d '\n')
else
    paste=$(echo "$content" | tr -d '\n')
fi

tmux send-keys "$paste"

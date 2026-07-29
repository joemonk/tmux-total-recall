#!/usr/bin/env bash
# Browse tmux buffers with fzf, paste selected (key only if key="label" format)
CACHE_FILE="${1:-}"
SOURCES="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

selected=$(
    "$SCRIPT_DIR/list-buffers.sh" \
    | fzf --with-nth 2.. \
          --delimiter ': ' \
          --header 'enter: paste  ctrl-d: delete' \
          --preview "$SCRIPT_DIR/preview.sh {1}" \
          --preview-window right:40% \
          --bind "ctrl-d:execute($SCRIPT_DIR/delete.sh {1} '$CACHE_FILE' '$SOURCES')+reload($SCRIPT_DIR/list-buffers.sh)"
)

[ -z "$selected" ] && exit 0

buf_name=$(echo "$selected" | sed 's/: .*//')
tmux show-buffer -b "$buf_name" \
    | awk '{
        if (index($0, " = \"") > 0 && $0 ~ /^[^ ]+ = ".*"$/) {
            print $1
        } else {
            print $0
        }
    }' \
    | tr -d '\n' \
    | tmux load-buffer -
tmux paste-buffer

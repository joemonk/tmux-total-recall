#!/usr/bin/env bash
# Browse saved snippets and tmux buffers with fzf, paste selected command
CACHE_FILE="${1:-}"
SOURCES="${2:-}"
DELIMITER="${3:- ::=:: }"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

selected=$(
    "$SCRIPT_DIR/list-buffers.sh" "$DELIMITER" "$CACHE_FILE" "$SOURCES" \
    | fzf --with-nth 2.. \
          --delimiter ': ' \
          --header 'enter: paste  ctrl-d: delete' \
          --preview "$SCRIPT_DIR/preview.sh {1} '$DELIMITER'" \
          --preview-window right:40% \
          --bind "ctrl-d:execute($SCRIPT_DIR/delete.sh {1})+reload($SCRIPT_DIR/list-buffers.sh '$DELIMITER' '$CACHE_FILE' '$SOURCES')"
)

[ -z "$selected" ] && exit 0

ref=$(echo "$selected" | sed 's/: .*//')

if echo "$ref" | grep -q '^buf:'; then
    bufname=$(echo "$ref" | sed 's/^buf://')
    tmux show-buffer -b "$bufname" \
        | tr -d '\n' \
        | tmux load-buffer -b total-recall-paste -
else
    filepath=$(echo "$ref" | sed 's/:[0-9]*$//')
    linenum=$(echo "$ref" | grep -oE '[0-9]+$')
    sed -n "${linenum}p" "$filepath" \
        | awk -v delim="$DELIMITER" '{
            pos = index($0, delim)
            if (pos > 0) { print substr($0, 1, pos - 1) }
            else { print $0 }
        }' \
        | tr -d '\n' \
        | tmux load-buffer -b total-recall-paste -
fi

tmux paste-buffer -p -b total-recall-paste

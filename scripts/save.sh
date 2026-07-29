#!/usr/bin/env bash
# Save a command to the cache file, optionally with a label
CACHE_FILE="${1:-$HOME/.tmux-total-recall}"
AUTO="${2:-}"
HISTORY_FILE="${3:-$HOME/.zsh_history}"
DELIMITER="${4:- ::=:: }"

if [ "$AUTO" = "auto" ]; then
    last=$(tail -1 "$HISTORY_FILE")
    if echo "$last" | grep -q '^:[^;]*;'; then
        CMD=$(echo "$last" | sed 's/^:[^;]*;//')
    else
        CMD="$last"
    fi
else
    CMD=""
fi

echo -n "Command: "
read -rei "$CMD" CMD
[ -z "$CMD" ] && exit 0

echo -n "Label (optional, Enter to skip): "
read -r LABEL

if [ -n "$LABEL" ]; then
    LINE="$CMD$DELIMITER$LABEL"
else
    LINE="$CMD"
fi

echo "$LINE" >> "$CACHE_FILE"
printf '%s' "$LINE" | tmux load-buffer -
echo "Saved: $LINE"
sleep 0.8

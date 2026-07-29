#!/usr/bin/env bash
# Save a command to the cache file, optionally with a label
CACHE_FILE="${1:-$HOME/.tmux-total-recall}"
KEY_PATTERN="${2:-^[^ ]+ = \".*\"\$}"
AUTO="${3:-}"
HISTORY_FILE="${4:-$HOME/.zsh_history}"

if [ "$AUTO" = "auto" ]; then
    last=$(tail -1 "$HISTORY_FILE")
    # zsh extended history format: `: timestamp:elapsed;command`
    if echo "$last" | grep -q '^:[^;]*;'; then
        CMD=$(echo "$last" | sed 's/^:[^;]*;//')
    else
        # bash / plain history
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
    LINE="$CMD = \"$LABEL\""
else
    LINE="$CMD"
fi

echo "$LINE" >> "$CACHE_FILE"
printf '%s' "$LINE" | tmux load-buffer -
echo "Saved: $LINE"
sleep 0.8

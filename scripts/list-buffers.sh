#!/usr/bin/env bash
# List entries from files and tmux buffers for fzf
DELIMITER="${1:- ::=:: }"
CACHE_FILE="${2:-}"
SOURCES="${3:-}"

SEEN_FILE=$(mktemp)
trap 'rm -f "$SEEN_FILE"' EXIT

emit() {
    local label="$1"
    local ref="$2"
    grep -qxF "$label" "$SEEN_FILE" && return
    echo "$label" >> "$SEEN_FILE"
    echo "$ref: $label"
}

# Read from cache and source files first
for f in "$CACHE_FILE" $SOURCES; do
    [ -f "$f" ] || continue
    linenum=0
    while IFS= read -r line; do
        linenum=$((linenum + 1))
        [ -z "$line" ] && continue
        label=$(printf '%s' "$line" | awk -v delim="$DELIMITER" '{
            pos = index($0, delim)
            if (pos > 0) { print substr($0, pos + length(delim)) }
            else { print $0 }
        }')
        emit "$label" "$f:$linenum"
    done < "$f"
done

# Then add tmux buffers not already seen
while read -r name; do
    content=$(tmux show-buffer -b "$name" 2>/dev/null)
    [ -z "$content" ] && continue
    label=$(printf '%s' "$content" | awk -v delim="$DELIMITER" '{
        pos = index($0, delim)
        if (pos > 0) { print substr($0, pos + length(delim)) }
        else { print $0 }
    }')
    emit "$label" "buf:$name"
done < <(tmux list-buffers -F '#{buffer_name}' 2>/dev/null)

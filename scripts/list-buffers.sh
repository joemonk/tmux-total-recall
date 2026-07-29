#!/usr/bin/env bash
# List entries from files and tmux buffers for fzf
# Output format: "source_ref: display_label"
# source_ref is either "filepath:linenum" (file entry) or "buf:buffername" (tmux buffer)
DELIMITER="${1:- ::=:: }"
CACHE_FILE="${2:-}"
SOURCES="${3:-}"

seen=()

is_seen() {
    local key="$1"
    for s in "${seen[@]}"; do [ "$s" = "$key" ] && return 0; done
    return 1
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
        is_seen "$label" && continue
        seen+=("$label")
        echo "$f:$linenum: $label"
    done < "$f"
done

# Then add tmux buffers not already seen
tmux list-buffers -F '#{buffer_name}' 2>/dev/null | while read -r name; do
    content=$(tmux show-buffer -b "$name" 2>/dev/null)
    [ -z "$content" ] && continue
    label=$(printf '%s' "$content" | awk -v delim="$DELIMITER" '{
        pos = index($0, delim)
        if (pos > 0) { print substr($0, pos + length(delim)) }
        else { print $0 }
    }')
    is_seen "$label" && continue
    seen+=("$label")
    echo "buf:$name: $label"
done

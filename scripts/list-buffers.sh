#!/usr/bin/env bash
# List entries from cache and source files for fzf
# Output format: "filepath:linenum: display_label"
DELIMITER="${1:- ::=:: }"
CACHE_FILE="${2:-}"
SOURCES="${3:-}"

seen=()

for f in "$CACHE_FILE" $SOURCES; do
    [ -f "$f" ] || continue
    linenum=0
    while IFS= read -r line; do
        linenum=$((linenum + 1))
        [ -z "$line" ] && continue
        # extract label for display
        label=$(printf '%s' "$line" | awk -v delim="$DELIMITER" '{
            pos = index($0, delim)
            if (pos > 0) { print substr($0, pos + length(delim)) }
            else { print $0 }
        }')
        # dedup by label
        dupe=0
        for s in "${seen[@]}"; do [ "$s" = "$label" ] && dupe=1 && break; done
        [ "$dupe" = "1" ] && continue
        seen+=("$label")
        echo "$f:$linenum: $label"
    done < "$f"
done

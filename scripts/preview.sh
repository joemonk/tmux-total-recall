#!/usr/bin/env bash
# Preview what will be pasted - reads from file:linenum reference
REF="$1"  # format: filepath:linenum
DELIMITER="${2:- ::=:: }"

filepath=$(echo "$REF" | sed 's/:[0-9]*$//')
linenum=$(echo "$REF" | grep -oE '[0-9]+$')

sed -n "${linenum}p" "$filepath" 2>/dev/null | awk -v delim="$DELIMITER" '{
    pos = index($0, delim)
    if (pos > 0) { print substr($0, 1, pos - 1) }
    else { print $0 }
}'

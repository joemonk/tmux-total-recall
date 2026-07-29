#!/usr/bin/env bash
# Delete an entry - removes line from file by file:linenum reference
REF="$1"  # format: filepath:linenum

filepath=$(echo "$REF" | sed 's/:[0-9]*$//')
linenum=$(echo "$REF" | grep -oE '[0-9]+$')

[ -f "$filepath" ] || exit 0

# BSD sed (macOS) requires a backup extension, use empty string with -e trick
if sed --version 2>/dev/null | grep -q GNU; then
    sed -i "${linenum}d" "$filepath"
else
    sed -i '' "${linenum}d" "$filepath"
fi

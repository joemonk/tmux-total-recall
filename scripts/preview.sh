#!/usr/bin/env bash
# Preview what will be pasted for a given buffer name
BUF_NAME="$1"
tmux show-buffer -b "$BUF_NAME" 2>/dev/null | awk '{
    if (index($0, " = \"") > 0 && $0 ~ /^[^ ]+ = ".*"$/) {
        print $1
    } else {
        print $0
    }
}'

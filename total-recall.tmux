#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default options
default_bind_browse="b"
default_bind_save="a"
default_bind_save_auto="A"
default_cache_file="$HOME/.tmux-total-recall"
default_sources=""
default_key_pattern="^[^ ]+ = \".*\"\$"

get_opt() {
    local opt="$1"
    local default="$2"
    local val
    val=$(tmux show-option -gqv "$opt")
    echo "${val:-$default}"
}

bind_browse=$(get_opt "@total-recall-bind-browse" "$default_bind_browse")
bind_save=$(get_opt "@total-recall-bind-save" "$default_bind_save")
bind_save_auto=$(get_opt "@total-recall-bind-save-auto" "$default_bind_save_auto")
cache_file=$(get_opt "@total-recall-cache-file" "$default_cache_file")
sources=$(get_opt "@total-recall-sources" "$default_sources")
key_pattern=$(get_opt "@total-recall-key-pattern" "$default_key_pattern")

# Touch cache file and load it
tmux run-shell "touch '$cache_file'"
tmux run-shell "$CURRENT_DIR/scripts/load-buffers.sh '$cache_file'"

# Load extra source files
for src in $sources; do
    tmux run-shell "touch '$src'"
    tmux run-shell "$CURRENT_DIR/scripts/load-buffers.sh '$src'"
done

# Bindings
tmux bind-key "$bind_browse" display-popup -E \
    "$CURRENT_DIR/scripts/browse.sh '$key_pattern'"

tmux bind-key "$bind_save" display-popup -E \
    "$CURRENT_DIR/scripts/save.sh '$cache_file' '$key_pattern'"

tmux bind-key "$bind_save_auto" display-popup -E \
    "$CURRENT_DIR/scripts/save.sh '$cache_file' '$key_pattern' auto"

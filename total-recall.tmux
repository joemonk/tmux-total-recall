#!/usr/bin/env bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default options
default_bind_browse="b"
default_bind_save="a"
default_bind_save_auto="A"
default_cache_file="$HOME/.tmux-total-recall"
default_sources=""
default_history_file="$HOME/.zsh_history"
default_delimiter=" ::=:: "

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
history_file=$(get_opt "@total-recall-history-file" "$default_history_file")
delimiter=$(get_opt "@total-recall-delimiter" "$default_delimiter")

# Ensure cache file exists
tmux run-shell "touch '$cache_file'"

# Bindings
tmux bind-key "$bind_browse" display-popup -E \
    "$CURRENT_DIR/scripts/browse.sh '$cache_file' '$sources' '$delimiter'"

tmux bind-key "$bind_save" display-popup -E \
    "$CURRENT_DIR/scripts/save.sh '$cache_file' '' '$history_file' '$delimiter'"

tmux bind-key "$bind_save_auto" display-popup -E \
    "$CURRENT_DIR/scripts/save.sh '$cache_file' auto '$history_file' '$delimiter'"

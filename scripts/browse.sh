#!/usr/bin/env bash
# Browse tmux buffers with fzf, paste selected (key only if key="label" format)
CACHE_FILE="${1:-}"
SOURCES="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Extract paste value: if line matches `key = "label"`, return key, else return whole line
extract() {
    awk 'index($0, " = \"") && /^[^ ]+ = ".*"$/ {print $1; exit} {print}'
}

# Build label for display: show quoted label if key="label" format, else full content
label_of() {
    awk 'index($0, " = \"") && /^[^ ]+ = ".*"$/ {match($0, /"(.*)"/,a); print a[1]; exit} {print}'
}

selected=$(
    tmux list-buffers -F '#{buffer_name}' | while read -r name; do
        content=$(tmux show-buffer -b "$name" 2>/dev/null)
        label=$(echo "$content" | label_of)
        echo "$name: $label"
    done \
    | awk '!seen[$2]++' \
    | fzf --with-nth 2.. \
          --delimiter ': ' \
          --header 'enter: paste  ctrl-d: delete' \
          --preview "tmux show-buffer -b {1} | awk 'index(\$0, \" = \\\"\") && /^[^ ]+ = \".*\"\$/ {print \$1; exit} {print}'" \
          --preview-window right:40% \
          --bind "ctrl-d:execute($SCRIPT_DIR/delete.sh {1} '$CACHE_FILE' '$SOURCES')+reload(
              tmux list-buffers -F '#{buffer_name}' | while read -r n; do
                  c=\$(tmux show-buffer -b \"\$n\" 2>/dev/null);
                  l=\$(echo \"\$c\" | awk 'index(\$0, \" = \\\"\") && /^[^ ]+ = \".*\"\$/ {match(\$0, /\"(.*)\"/,a); print a[1]; exit} {print}');
                  echo \"\$n: \$l\";
              done | awk '!seen[\$2]++'
          )"
)

[ -z "$selected" ] && exit 0

buf_name=$(echo "$selected" | sed 's/: .*//')
tmux show-buffer -b "$buf_name" \
    | awk 'index($0, " = \"") && /^[^ ]+ = ".*"$/ {print $1; exit} {print}' \
    | tr -d '\n' \
    | tmux load-buffer -
tmux paste-buffer

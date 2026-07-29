#!/usr/bin/env bash
# Browse tmux buffers with fzf, paste selected (key only if key="label" format)
KEY_PATTERN="${1:-^[^ ]+ = \".*\"\$}"
CACHE_FILE="${2:-}"
SOURCES="${3:-}"

selected=$(
    tmux list-buffers -F '#{buffer_name}' | while read -r name; do
        content=$(tmux show-buffer -b "$name" 2>/dev/null)
        label=$(echo "$content" | awk -v pat="$KEY_PATTERN" '$0 ~ pat {match($0, /"(.*)"/,a); print a[1]; exit} {print}')
        echo "$name: $label"
    done \
    | awk '!seen[$2]++' \
    | fzf --with-nth 2.. \
          --delimiter ': ' \
          --header 'enter: paste  ctrl-d: delete' \
          --preview "tmux show-buffer -b {1} | awk -v pat='$KEY_PATTERN' '\$0 ~ pat {print \$1; exit} {print}'" \
          --preview-window right:40% \
          --bind "ctrl-d:execute(
              name=\$(echo {} | sed 's/: .*//');
              content=\$(tmux show-buffer -b \"\$name\" 2>/dev/null);
              tmux delete-buffer -b \"\$name\";
              for f in '$CACHE_FILE' $SOURCES; do
                  [ -f \"\$f\" ] && sed -i \"/^\$(echo \"\$content\" | sed 's/[^^]/[&]/g; s/\\^/\\\\^/g')\$/d\" \"\$f\";
              done
          )+reload(
              tmux list-buffers -F '#{buffer_name}' | while read -r n; do
                  c=\$(tmux show-buffer -b \"\$n\" 2>/dev/null);
                  l=\$(echo \"\$c\" | awk -v pat='$KEY_PATTERN' '\$0 ~ pat {match(\$0, /\"(.*)\"/,a); print a[1]; exit} {print}');
                  echo \"\$n: \$l\";
              done | awk '!seen[\$2]++'
          )"
)

[ -z "$selected" ] && exit 0

buf_name=$(echo "$selected" | sed 's/: .*//')
tmux show-buffer -b "$buf_name" \
    | awk -v pat="$KEY_PATTERN" '$0 ~ pat {print $1; exit} {print}' \
    | tr -d '\n' \
    | tmux load-buffer -
tmux paste-buffer

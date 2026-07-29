# tmux-total-recall

![demo](demo.gif)

A tmux plugin for managing a personal buffer library — search, paste, and save commands and snippets using fzf.

Supports a `key = "label"` format: display the human-readable label in the picker but paste only the key.

## Features

- Browse all tmux buffers with fzf, deduped by content
- `key = "label"` format: shows label, pastes key (e.g. `mytoken = "API token"` → pastes `mytoken`)
- Preview pane shows exactly what will be pasted
- Save commands manually or auto-capture from zsh history
- Configurable cache file, source files, key bindings, and format pattern

## Installation

Using [tpm](https://github.com/tmux-plugins/tpm):

```
set -g @plugin 'joemonk/tmux-total-recall'
```

## Configuration

All options are optional — defaults work out of the box.

```tmux
# Key bindings (defaults shown)
set -g @total-recall-bind-browse    "b"   # open buffer picker
set -g @total-recall-bind-save      "a"   # manually save a command
set -g @total-recall-bind-save-auto "A"   # save last zsh history entry

# File where saved commands are stored (default: ~/.tmux-total-recall)
set -g @total-recall-cache-file "~/.tmux-total-recall"

# Extra files to load into buffers on startup (space-separated)
set -g @total-recall-sources "~/.my-snippets ~/work-commands"

# Shell history file for auto-save (default: ~/.zsh_history)
set -g @total-recall-history-file "~/.zsh_history"
```

## Shell history

The auto-save binding (`prefix + A`) reads the last entry from your history file. Configure it to match your shell:

| Shell | History file | Format |
|-------|-------------|--------|
| zsh | `~/.zsh_history` (default) | `: timestamp;command` — prefix stripped automatically |
| bash | `~/.bash_history` | plain commands |
| fish | not supported | fish uses a YAML format |

**bash example:**
```tmux
set -g @total-recall-history-file "~/.bash_history"
```

## The `key = "label"` format

Any line in your cache or source files matching the pattern `key = "label"` will:
- Display `label` in the fzf picker (searchable)
- Paste only `key` on selection

Lines not matching the pattern are shown and pasted as-is.

**Example cache file:**
```
deploy-prod = "Deploy to production"
db-backup = "Database backup command"
```

Search "Deploy", press Enter → pastes `deploy-prod`.

## Dependencies

- [fzf](https://github.com/junegunn/fzf)
- zsh (for auto-save from history; bash history also works with minor config)

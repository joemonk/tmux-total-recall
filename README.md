# tmux-total-recall

![demo](demo.gif)

A tmux plugin for managing a personal buffer library — search, paste, and save commands and snippets using fzf.

## Features

- Browse all tmux buffers with fzf, deduped by content
- `command ::=:: label` format: shows label in picker, pastes only the command
- Preview pane shows exactly what will be pasted
- `ctrl-d` to delete an entry from the picker
- Save commands manually or auto-capture from shell history
- Configurable cache file, source files, key bindings, and delimiter

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
set -g @total-recall-bind-save-auto "A"   # save last shell history entry

# File where saved commands are stored (default: ~/.tmux-total-recall)
set -g @total-recall-cache-file "~/.tmux-total-recall"

# Extra files to load into buffers on startup (space-separated)
set -g @total-recall-sources "~/.my-snippets ~/work-commands"

# Shell history file for auto-save (default: ~/.zsh_history)
set -g @total-recall-history-file "~/.zsh_history"

# Delimiter between command and label (default: " ::=:: ")
set -g @total-recall-delimiter " ::=:: "
```

## The `command ::=:: label` format

Any line saved with a label uses the delimiter to separate the command from its display name:

```
ls -la ::=:: list all files
cd ~ ::=:: go home
openstack server list
```

- The label is shown in the fzf picker (searchable)
- Only the command is pasted on selection
- Lines without the delimiter are shown and pasted as-is

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

## Dependencies

- [fzf](https://github.com/junegunn/fzf)

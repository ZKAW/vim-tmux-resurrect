# tmux-resurrect.nvim

A Neovim/Vim plugin to browse and restore `tmux-resurrect` sessions using Telescope, with session previews and timestamps.

## Installation

### Using `lazy.nvim` or `plug`
`ZKAW/vim-tmux-resurrect`

> Requires:
> - `nvim-telescope/telescope.nvim`
> - `nvim-lua/plenary.nvim`
> - `tmux-resurrect` installed and previously saved sessions

## Usage

* Use `:TmuxResurrect` to open a Telescope picker of saved tmux sessions.
* Browse the list with preview support for panes and commands.

##### Example of setup function:
```lua
require("tmux_resurrect").setup()
```

## Notes

* Make sure you've used `tmux-resurrect` to save sessions before running this plugin.
* Session files are read from `~/.local/share/tmux/resurrect/`.

# kiro.nvim

Neovim plugin for [Kiro AI](https://kiro.ai) chat integration with minimal dependencies.

## Prerequisites

- Neovim 0.5+
- [kiro-cli](https://kiro.ai) installed and configured

## Installation

### lazy.nvim

```lua
{
  'seagoj/kiro.nvim',
}
```

### packer.nvim

```lua
use 'seagoj/kiro.nvim'
```

### vim-plug

```vim
Plug 'seagoj/kiro.nvim'
```

## Commands

| Command | Description |
|---------|-------------|
| `:KiroBuffer` | Open Kiro chat with current file context |
| `:KiroChat` | Same as `:KiroBuffer` |
| `:KiroExplain` | Explain the code in context |
| `:KiroFix` | Fix code based on FIXME comment |
| `:KiroOptimize` | Refactor for optimization |
| `:KiroRefactor` | Refactor for readability |

All commands support visual selection ranges. Select lines in visual mode and run a command to include only those lines in the context.

## Usage

```vim
" Open chat with current file
:KiroBuffer

" Explain selected code (in visual mode)
:'<,'>KiroExplain

" Fix code at cursor
:KiroFix
```

## Roadmap
- [ ] Reuse terminal windows
- [ ] Optional toggleterm integration

## License

MIT

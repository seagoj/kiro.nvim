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
  opts = {
    default_commands = true,  -- Enable default commands (default: false)
    split = 'vsplit',         -- Split direction: 'split' or 'vsplit' (default: 'vsplit')
  }
}
```

### packer.nvim

```lua
use {
  'seagoj/kiro.nvim',
  config = function()
    require('kiro').setup({
      default_commands = true,  -- Enable default commands (default: false)
      split = 'vsplit',         -- Split direction: 'split' or 'vsplit' (default: 'vsplit')
    })
  end
}
```

### vim-plug

```vim
Plug 'seagoj/kiro.nvim'

" In your init.vim, after plug#end()
lua << EOF
require('kiro').setup({
  default_commands = true,  -- Enable default commands (default: false)
  split = 'vsplit',         -- Split direction: 'split' or 'vsplit' (default: 'vsplit')
})
EOF
```

## Configuration

- `default_commands` (boolean, default: `false`) - When enabled, automatically registers all Kiro commands (`:KiroBuffer`, `:KiroChat`, `:KiroExplain`, `:KiroFix`, `:KiroOptimize`, `:KiroRefactor`). When disabled, you can manually register only the commands you want using `require('kiro').register_command()`.
- `split` (string, default: `'vsplit'`) - Terminal split direction. Options: `'split'` (horizontal) or `'vsplit'` (vertical).

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

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
    register_default_commands = true,  -- Enable default commands (default: true)
    split = 'vsplit',                  -- Split direction: 'split' or 'vsplit' (default: 'vsplit')
    commands = {},                     -- Custom commands (default: {})
    reuse_terminal = true,             -- Reuse existing terminal window (default: true)
    auto_insert_mode = true,           -- Auto enter insert mode (default: true)
  }
}
```

### packer.nvim

```lua
use {
  'seagoj/kiro.nvim',
  config = function()
    require('kiro').setup({
      register_default_commands = true,  -- Enable default commands (default: true)
      split = 'vsplit',                  -- Split direction: 'split' or 'vsplit' (default: 'vsplit')
      commands = {},                     -- Custom commands (default: {})
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
  register_default_commands = true,  -- Enable default commands (default: true)
  split = 'vsplit',                  -- Split direction: 'split' or 'vsplit' (default: 'vsplit')
  commands = {},                     -- Custom commands (default: {})
})
EOF
```

## Configuration

- `register_default_commands` (boolean, default: `true`) - When enabled, automatically registers the `:KiroBuffer` command. When disabled, you can manually register custom commands using `require('kiro').register_command()`.
- `split` (string, default: `'vsplit'`) - Terminal split direction. Options: `'split'` (horizontal) or `'vsplit'` (vertical).
- `commands` (table, default: `{}`) - Define custom commands in setup. Keys are command names, values are prompts.
- `reuse_terminal` (boolean, default: `true`) - Reuse existing terminal window instead of creating new ones for each command.
- `auto_insert_mode` (boolean, default: `true`) - Automatically enter insert mode when opening or focusing the terminal.

## Commands

The plugin provides one built-in command when `register_commands = true`:

| Command | Description |
|---------|-------------|
| `:KiroBuffer` | Open Kiro chat with current file context |

All commands support visual selection ranges. Select lines in visual mode and run a command to include only those lines in the context.

## Usage

```vim
" Open chat with current file
:KiroBuffer

" Open chat with selected code (in visual mode)
:'<,'>KiroBuffer
```

## Custom Commands

You can create your own commands with custom prompts:

```lua
-- In your init.lua after setup
local kiro = require('kiro')

-- Register custom commands
kiro.register_command('KiroExplain', 'Explain the code in')
kiro.register_command('KiroFix', 'Fix the code in')
kiro.register_command('KiroOptimize', 'Optimize the code in')
kiro.register_command('KiroRefactor', 'Refactor for readability the code in')
```

Then use them:

```vim
" Explain selected code (in visual mode)
:'<,'>KiroExplain

" Fix code at cursor
:KiroFix
```

## Examples

Here are some useful custom commands you can add to your configuration:

```lua
-- In your init.lua after setup
local kiro = require('kiro')

-- Code explanation
kiro.register_command('KiroExplain', 'Explain the code in')

-- Bug fixing
kiro.register_command('KiroFix', 'Fix the code in')

-- Performance optimization
kiro.register_command('KiroOptimize', 'Optimize the code in')

-- Refactoring
kiro.register_command('KiroRefactor', 'Refactor for readability the code in')

-- Add tests
kiro.register_command('KiroTest', 'Write tests for the code in')

-- Documentation
kiro.register_command('KiroDoc', 'Add documentation to the code in')
```

## Roadmap
- [x] Reuse terminal windows
- [ ] Optional toggleterm integration
- [ ] Consume and use any lsps from .kiro/settings/lsp.json

## License

MIT

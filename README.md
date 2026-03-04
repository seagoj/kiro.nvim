# kiro.nvim

[![Tests](https://github.com/seagoj/kiro.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/seagoj/kiro.nvim/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/seagoj/kiro.nvim/branch/main/graph/badge.svg)](https://codecov.io/gh/seagoj/kiro.nvim)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Neovim plugin for [Kiro AI](https://kiro.ai) chat integration with minimal dependencies.

## Prerequisites

- Neovim 0.9+
- [kiro-cli](https://kiro.ai) installed and configured

## Installation

### lazy.nvim

```lua
{
  'seagoj/kiro.nvim',
  opts = {
    register_default_commands = true,  -- Enable default commands (default: true)
    split = 'vsplit',                  -- Split direction: 'split', 'vsplit', or 'float' (default: 'vsplit')
    commands = {},                     -- Custom commands (default: {})
    reuse_terminal = true,             -- Reuse existing terminal window (default: true)
    auto_insert_mode = true,           -- Auto enter insert mode (default: true)
    enable_lsp = true,                 -- Enable LSP integration (default: true)
    float_opts = {                     -- Floating window options (only for split = 'float')
      width = 0.8,                     -- Width as percentage of screen (default: 0.8)
      height = 0.8,                    -- Height as percentage of screen (default: 0.8)
      row = nil,                       -- Row position (default: centered)
      col = nil,                       -- Column position (default: centered)
    },
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
      split = 'vsplit',                  -- Split direction: 'split', 'vsplit', or 'float' (default: 'vsplit')
      commands = {},                     -- Custom commands (default: {})
      enable_lsp = true,                 -- Enable LSP integration (default: true)
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
  split = 'vsplit',                  -- Split direction: 'split', 'vsplit', or 'float' (default: 'vsplit')
  commands = {},                     -- Custom commands (default: {})
  enable_lsp = true,                 -- Enable LSP integration (default: true)
})
EOF
```

## Configuration

- `register_default_commands` (boolean, default: `true`) - When enabled, automatically registers the `:KiroBuffer` command. When disabled, you can manually register custom commands using `require('kiro').register_command()`.
- `split` (string, default: `'vsplit'`) - Terminal split direction. Options: `'split'` (horizontal), `'vsplit'` (vertical), or `'float'` (floating window).
- `commands` (table, default: `{}`) - Define custom commands in setup. Keys are command names, values are prompts.
- `reuse_terminal` (boolean, default: `true`) - Reuse existing terminal window instead of creating new ones for each command.
- `auto_insert_mode` (boolean, default: `true`) - Automatically enter insert mode when opening or focusing the terminal.
- `keymaps` (table, default: `{close = "<C-q>", resend = "<C-r>"}`) - Buffer-local keymaps for the terminal. Set to `false` to disable a keymap.
- `terminal_size` (number, optional) - Size of the terminal split in lines (for horizontal) or columns (for vertical). If not set, uses Neovim's default split size.
- `profile` (string, optional) - kiro-cli profile to use. Corresponds to `kiro-cli chat --profile <name>`.
- `enable_lsp` (boolean, default: `true`) - Enable automatic LSP configuration from `.kiro/settings/lsp.json`.
- `use_toggleterm` (boolean, default: `false`) - Use [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) for terminal management if available.
- `float_opts` (table, optional) - Floating window options (only used when `split = 'float'`):
  - `width` (number, default: `0.8`) - Width as percentage of screen (0.0 to 1.0)
  - `height` (number, default: `0.8`) - Height as percentage of screen (0.0 to 1.0)
  - `row` (number, optional) - Row position (default: centered)
  - `col` (number, optional) - Column position (default: centered)

### Project-Specific Configuration

Create a `.kiro.lua` file in your project root to override global settings:

```lua
-- .kiro.lua
return {
  split = 'float',
  profile = 'work',
  commands = {
    KiroReview = 'Review this code in',
    KiroTest = 'Generate tests for',
  },
}
```

Project config takes precedence over global config. See `examples/.kiro.lua` for a complete example.

### Terminal Size

Control the size of the terminal split:

```lua
require('kiro').setup({
  split = 'vsplit',
  terminal_size = 80,  -- 80 columns wide for vertical split
})

-- Or for horizontal split
require('kiro').setup({
  split = 'split',
  terminal_size = 20,  -- 20 lines tall for horizontal split
})
```

### Profiles

Use different kiro-cli profiles for different contexts:

```lua
require('kiro').setup({
  profile = 'work',  -- Uses: kiro-cli chat --profile work
})
```

### Toggleterm Integration

If you have [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) installed, you can use it for terminal management:

```lua
require('kiro').setup({
  use_toggleterm = true,
})
```

This provides better terminal management with toggleterm's features like persistent terminals and easier toggling. Falls back to default terminal if toggleterm is not available.

### Floating Window

Use a floating window for a more focused chat experience:

```lua
require('kiro').setup({
  split = 'float',
  float_opts = {
    width = 0.9,   -- 90% of screen width
    height = 0.9,  -- 90% of screen height
  },
})
```

### LSP Integration

The plugin automatically loads and configures LSP servers from `.kiro/settings/lsp.json` if present. This file is typically created by running `kiro-cli /code init` in your project.

Example `.kiro/settings/lsp.json`:

```json
{
  "lua_ls": {
    "cmd": ["lua-language-server"],
    "filetypes": ["lua"],
    "root_dir": "."
  },
  "rust_analyzer": {
    "cmd": ["rust-analyzer"],
    "filetypes": ["rust"],
    "root_dir": "."
  }
}
```

The plugin will automatically start these LSP servers for the configured file types when you open files in Neovim.

### Keymaps

When in the Kiro terminal buffer (normal mode):
- `<C-q>` - Close the terminal
- `<C-r>` - Resend the last message

Customize keymaps in your config:

```lua
require('kiro').setup({
  keymaps = {
    close = "<leader>q",  -- Custom close keymap
    resend = "<leader>r", -- Custom resend keymap
  }
})
```

## Commands

The plugin provides built-in commands:

| Command | Description |
|---------|-------------|
| `:KiroBuffer` | Open Kiro chat with current file context |
| `:KiroSession [name]` | Get or set current terminal session |
| `:KiroSessions` | List all terminal sessions |
| `:KiroLspStatus` | Show LSP server status (if LSP enabled) |
| `:KiroCheckConfig` | Validate current configuration |

All commands support visual selection ranges. Select lines in visual mode and run a command to include only those lines in the context.

## Usage

```vim
" Open chat with current file
:KiroBuffer

" Open chat with selected code (in visual mode)
:'<,'>KiroBuffer
```

### Lua API

You can also use the Lua API directly:

```lua
local kiro = require('kiro')

-- Close the terminal
kiro.close_terminal()

-- Resend the last message
kiro.resend()

-- Get command history
local history = kiro.get_history()
for i, msg in ipairs(history) do
  print(i, msg)
end

-- Send from history (1 = oldest, -1 = newest)
kiro.send_from_history(-1)  -- Send most recent
kiro.send_from_history(1)   -- Send oldest

-- Send with multiple files
kiro.send_with_files('Explain these files', {
  'lua/kiro/init.lua',
  'lua/kiro/config.lua',
})

-- Send with glob patterns
kiro.send_with_files('Review all Lua files', { 'lua/**/*.lua' })
kiro.send_with_files('Check tests', { 'tests/*_spec.lua' })

-- Mix explicit files and patterns
kiro.send_with_files('Review code', {
  'README.md',
  'lua/kiro/*.lua',
  'tests/*_spec.lua',
})

-- Clear terminal and history
kiro.clear_terminal()

-- Clear history
kiro.clear_history()
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

## Health Check

Check that kiro-cli is properly installed:

```vim
:checkhealth kiro
```

This verifies:
- kiro-cli is installed and in PATH

## Troubleshooting

### kiro-cli not found

**Problem:** Error message "kiro-cli not found in PATH"

**Solution:**
1. Install kiro-cli from [kiro.ai](https://kiro.ai)
2. Verify installation: `which kiro-cli` or `kiro-cli --version`
3. Ensure it's in your PATH
4. Restart Neovim after installation

### Terminal doesn't open

**Problem:** Nothing happens when running commands

**Solution:**
1. Run `:checkhealth kiro` to verify setup
2. Enable debug mode to see what's happening:
   ```lua
   require('kiro').setup({ debug = true })
   ```
3. Check `:messages` for error details
4. Verify you have a file open (not an empty buffer)

### Keymaps not working

**Problem:** `<C-q>` or `<C-r>` don't work in terminal

**Solution:**
1. Ensure you're in normal mode (press `<Esc>` first)
2. Verify you're in the Kiro terminal buffer
3. Check keymap configuration:
   ```lua
   require('kiro').setup({
     keymaps = {
       close = '<C-q>',
       resend = '<C-r>',
     }
   })
   ```
4. Test with `:nmap <C-q>` in the terminal buffer

### File context not included

**Problem:** Kiro doesn't receive file information

**Solution:**
1. Ensure you have a saved file open (not `[No Name]`)
2. Check file is readable: `:echo filereadable(expand('%'))`
3. Enable debug mode to see context building
4. For visual selections, ensure you're using `:'<,'>KiroBuffer`

### Messages not sending

**Problem:** Terminal opens but messages don't send

**Solution:**
1. Check kiro-cli is working: `kiro-cli chat "test"` in your shell
2. Look for error messages in the terminal buffer
3. Try disabling terminal reuse:
   ```lua
   require('kiro').setup({ reuse_terminal = false })
   ```
4. Enable debug logging for details

### Getting help

For more help:
- Read the docs: `:help kiro.nvim`
- Check issues: https://github.com/seagoj/kiro.nvim/issues
- Enable debug mode and check `:messages`

## Roadmap
- [x] Reuse terminal windows
- [x] Command history/recall
- [x] Optional toggleterm integration
- [x] Consume and use any lsps from .kiro/settings/lsp.json

## License

MIT

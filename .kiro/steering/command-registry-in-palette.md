# Command Registry in Palette

## Summary

Enhanced `:KiroCommands` to show all registered commands (built-in and custom) in the command palette with telescope integration and vim.ui.select fallback.

## Changes

### 1. Command Registry (`lua/kiro/commands.lua`)

Added tracking of all registered commands:

```lua
local _registered_commands = {}

function M.register(name, prompt, terminal, config)
  -- Track in registry
  _registered_commands[name] = {
    name = name,
    prompt = type(prompt) == "function" and "<function>" or prompt,
  }
  -- ... rest of registration
end

function M.get_all_commands()
  -- Returns sorted array of all registered commands
end
```

### 2. Palette Integration (`lua/kiro/palette.lua`)

Added `show_commands()` function:
- Uses telescope picker if available
- Falls back to vim.ui.select
- Shows command name and prompt
- Executes selected command

### 3. Telescope Picker (`lua/kiro/telescope/commands.lua`)

New telescope picker for commands:
- Fuzzy searchable by name and prompt
- Shows formatted display: "CommandName - prompt text"
- Executes command on selection

### 4. Updated Command Registration

`:KiroCommands` now uses the palette system instead of filtering vim commands.

## Usage

**Command Palette:**
```vim
:KiroCommands
```

Shows all registered commands including:
- Built-in commands (KiroBuffer, KiroHistory, etc.)
- Custom commands registered via `kiro.register_command()`

**Telescope:**
```lua
require('telescope').extensions.kiro.commands()
```

**Display Format:**
```
KiroBuffer - 
KiroExplain - Explain the code in
KiroFix - Fix the code in
KiroTest - Write tests for the code in
```

## Benefits

1. **Discoverability** - Users can see all available commands
2. **Custom Commands** - Custom commands appear alongside built-in ones
3. **Searchable** - Fuzzy search by name or prompt (with telescope)
4. **Consistent** - Same UX as other palette features

## Testing

Added test to verify command tracking:
- Registers multiple commands
- Retrieves all commands via `get_all_commands()`
- Verifies names and prompts are tracked

Total tests: 64 → 65 (+1)

## Example

```lua
-- Register custom commands
local kiro = require('kiro')
kiro.register_command('KiroExplain', 'Explain the code in')
kiro.register_command('KiroFix', 'Fix the code in')
kiro.register_command('KiroTest', 'Write tests for')

-- Open command palette
vim.cmd('KiroCommands')

-- Shows:
-- KiroBuffer - 
-- KiroExplain - Explain the code in
-- KiroFix - Fix the code in
-- KiroTest - Write tests for
-- ... (all other registered commands)
```

## Implementation Notes

- Commands tracked at registration time
- Registry persists for Neovim session
- Function prompts shown as "<function>"
- Commands sorted alphabetically
- No performance impact (simple table lookup)

# Command Palette Integration

## Problem

No easy way to browse command history, search conversations, or quickly access Kiro features.

## Requirements

1. Telescope/fzf integration for browsing
2. Search command history
3. Search conversation content
4. Quick session switching
5. Quick command selection

## Acceptance Criteria

- [ ] Telescope picker for command history
- [ ] Telescope picker for sessions
- [ ] Search within conversation history
- [ ] Fuzzy search support
- [ ] Preview in picker
- [ ] Fallback to vim.ui.select if telescope not available

## Configuration

```lua
require('kiro').setup({
  command_palette = true,        -- Enable palette (default: true)
  palette_backend = 'telescope', -- 'telescope', 'fzf', 'builtin'
})
```

## Commands

```vim
:KiroHistory       " Browse command history
:KiroSessions      " Browse sessions (already exists, enhance with picker)
:KiroSearch        " Search conversation content
:KiroCommands      " List available Kiro commands
```

## Telescope Pickers

### History Picker
```lua
require('telescope').extensions.kiro.history()
```

Shows:
- Recent commands
- Timestamp
- Preview of response (if available)

### Session Picker
```lua
require('telescope').extensions.kiro.sessions()
```

Shows:
- Session names
- Last used timestamp
- Message count
- Preview of last message

### Search Picker
```lua
require('telescope').extensions.kiro.search()
```

Searches:
- All messages in current session
- All messages across sessions (optional)
- Fuzzy search

## Fallback

If telescope not available, use `vim.ui.select`:
```lua
vim.ui.select(history, {
  prompt = 'Select command:',
  format_item = function(item)
    return item.message
  end
})
```

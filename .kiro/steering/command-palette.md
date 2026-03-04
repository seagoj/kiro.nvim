# Command Palette Implementation

**Date:** 2026-03-04  
**Spec:** `.kiro/specs/command-palette.md`  
**Task List:** `.kiro/tasks/command-palette.md`

## Overview

Implemented command palette with telescope integration and vim.ui.select fallback for browsing history, sessions, and searching conversations.

## Implementation

### Telescope Extension (`lua/kiro/telescope/`)

**init.lua** - Extension registration
- Checks telescope availability
- Registers extension with three pickers
- Returns functions that load pickers on demand

**history.lua** - History picker
- Shows command history in telescope
- Allows resending commands on selection
- Uses generic sorter for fuzzy search

**sessions.lua** - Sessions picker
- Shows available sessions
- Switches to selected session
- Notifies user of session change

**search.lua** - Search picker
- Searches through command history
- Uses telescope's fuzzy finder
- Read-only (no action on selection)

### Fallback Module (`lua/kiro/palette.lua`)

Provides three functions with automatic fallback:
- `show_history()` - Browse and resend commands
- `show_sessions()` - Browse and switch sessions
- `show_search()` - Search conversation history

Each function:
1. Checks if telescope is available
2. Uses telescope picker if available
3. Falls back to `vim.ui.select` otherwise
4. Shows appropriate message if no data

### Commands (`lua/kiro/commands.lua`)

Added `register_palette_commands()`:
- `:KiroHistory` - Calls `Palette.show_history()`
- `:KiroSearch` - Calls `Palette.show_search()`
- `:KiroCommands` - Lists all Kiro commands with picker

### Configuration (`lua/kiro/config.lua`)

Added two options:
- `command_palette` (boolean, default: true) - Enable/disable palette
- `palette_backend` (string, default: 'telescope') - Backend preference

Validation ensures `palette_backend` is 'telescope' or 'builtin'.

### Integration (`lua/kiro/init.lua`)

Calls `Commands.register_palette_commands(config)` during setup to register commands if `command_palette` is enabled.

## Design Decisions

**Minimal Implementation**
- No timestamps or metadata in pickers (can add later)
- Simple entry formatting (just the message text)
- No preview panes (telescope default behavior)

**Graceful Degradation**
- Telescope is optional, not required
- Falls back to vim.ui.select automatically
- No error if telescope not installed

**Lazy Loading**
- Telescope pickers loaded on demand
- Extension registered but pickers not loaded until used
- Minimal startup impact

**Simple API**
- Three main functions in palette module
- Each handles both telescope and fallback
- Consistent behavior across backends

## Testing

Created `tests/palette_spec.lua`:
- Tests vim.ui.select fallback for all three functions
- Tests empty state handling
- Tests session switching
- All tests pass (68 total)

## Limitations

**Current:**
- No timestamps in history
- No message count in sessions
- No preview panes
- Search is read-only (no action on selection)
- Sessions picker doesn't show metadata

**Future Enhancements:**
- Add timestamps to history entries
- Add session metadata (message count, last used)
- Add preview panes for longer messages
- Add actions to search results
- Support fzf-lua as alternative backend

## Files Modified

**Created:**
- `lua/kiro/telescope/init.lua` - Extension registration
- `lua/kiro/telescope/history.lua` - History picker
- `lua/kiro/telescope/sessions.lua` - Sessions picker
- `lua/kiro/telescope/search.lua` - Search picker
- `lua/kiro/palette.lua` - Fallback module
- `tests/palette_spec.lua` - Tests

**Modified:**
- `lua/kiro/commands.lua` - Added palette commands
- `lua/kiro/config.lua` - Added palette options
- `lua/kiro/init.lua` - Register palette commands
- `README.md` - Documented command palette

## Usage

**With Telescope:**
```vim
:KiroHistory   " Telescope picker
:KiroSearch    " Telescope search
:KiroCommands  " Telescope command list
```

**Without Telescope:**
```vim
:KiroHistory   " vim.ui.select fallback
:KiroSearch    " vim.ui.select fallback
:KiroCommands  " vim.ui.select fallback
```

**Lua API:**
```lua
require('telescope').extensions.kiro.history()
require('telescope').extensions.kiro.sessions()
require('telescope').extensions.kiro.search()
```

## Test Results

```
Total Tests: 68
Success: 68
Failed:  0
Errors:  0
```

All acceptance criteria met.

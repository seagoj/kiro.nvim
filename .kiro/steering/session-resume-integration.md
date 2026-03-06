# Session Resume Integration

**Date:** 2026-03-05  
**Spec:** `.kiro/specs/session-persistence.md`  
**Task List:** `.kiro/tasks/session-resume-integration.md`

## Overview

Implemented session resume integration that exposes kiro-cli's built-in session management features through Neovim commands and API.

## Implementation

### 1. Shell Command Building (`lua/kiro/terminal/shell.lua`)

Added support for resume flags:
- `opts.resume` → `--resume` flag
- `opts.resume_picker` → `--resume-picker` flag
- Empty message handling (no quotes when message is empty)

### 2. Session Parsing (`lua/kiro/terminal/shell.lua`)

Implemented `parse_sessions()` to parse `kiro-cli chat --list-sessions` output:
- Strips ANSI color codes
- Extracts session ID, time ago, preview, and message count
- Line-by-line parsing for robustness

### 3. Core API (`lua/kiro/init.lua`)

Added four new functions:
- `resume()` - Resume last conversation with `--resume`
- `resume_picker()` - Interactive picker with `--resume-picker`
- `get_saved_sessions()` - List all saved sessions
- `delete_session(id)` - Delete session by ID

### 4. Terminal Integration (`lua/kiro/terminal/init.lua`)

Added `open_with_command()` for custom kiro-cli commands:
- Accepts full command string
- Bypasses message building
- Used by resume functions

### 5. Commands (`lua/kiro/commands.lua`)

Registered four new commands:
- `:KiroResume` - Resume last conversation
- `:KiroResumePicker` - Pick session interactively
- `:KiroListSessions` - List all sessions with details
- `:KiroDeleteSession <id>` - Delete session (with completion)

### 6. Telescope Integration (`lua/kiro/telescope/sessions.lua`)

Enhanced sessions picker:
- `show_saved = true` option shows saved sessions
- Displays session metadata (ID, time, preview, count)
- Resume on selection

### 7. Palette Fallback (`lua/kiro/palette.lua`)

Updated `show_sessions()`:
- `show_saved` option for saved vs active sessions
- vim.ui.select fallback
- Formatted display with metadata

## Features

### Commands

```vim
:KiroResume              " Resume last conversation
:KiroResumePicker        " Pick session to resume
:KiroListSessions        " List all sessions
:KiroDeleteSession <id>  " Delete session by ID
```

### Lua API

```lua
local kiro = require('kiro')

-- Resume last conversation
kiro.resume()

-- Open session picker
kiro.resume_picker()

-- Get all saved sessions
local sessions, err = kiro.get_saved_sessions()
-- Returns: { { id, time_ago, preview, msg_count }, ... }

-- Delete session
kiro.delete_session('abc123')
```

### Telescope Integration

```lua
-- Show saved sessions
require('telescope').extensions.kiro.sessions({ show_saved = true })
```

## Testing

Added 12 new tests in `tests/session_resume_spec.lua`:
- Shell command building with flags
- Session parsing (including ANSI code stripping)
- API function exposure
- Command registration

All 77 tests pass (65 → 77, +18%).

## Benefits

1. **Leverages kiro-cli**: No reimplementation of session storage
2. **Consistent**: Same sessions across CLI and Neovim
3. **Complete**: Resume, list, and delete operations
4. **Integrated**: Works with telescope and command palette
5. **Tested**: Comprehensive test coverage

## User Impact

**Before:**
- No way to resume conversations from Neovim
- Had to exit to CLI to see/manage sessions
- Lost context when switching projects

**After:**
- Resume last conversation with `:KiroResume`
- Browse sessions with `:KiroResumePicker`
- Manage sessions without leaving Neovim
- Seamless integration with existing workflows

## Files Modified

**Created:**
- `tests/session_resume_spec.lua` - Test suite

**Modified:**
- `lua/kiro/init.lua` - Added 4 API functions
- `lua/kiro/commands.lua` - Added command registration
- `lua/kiro/terminal/init.lua` - Added `open_with_command()`
- `lua/kiro/terminal/shell.lua` - Added resume flags and parsing
- `lua/kiro/telescope/sessions.lua` - Added saved sessions support
- `lua/kiro/palette.lua` - Added saved sessions support
- `README.md` - Documented new commands

## Design Decisions

### Why Not Store Sessions in Plugin?

Kiro CLI already has robust session management. Reimplementing would:
- Duplicate functionality
- Risk inconsistency between CLI and plugin
- Add maintenance burden

### Session Parsing Approach

Used line-by-line parsing instead of complex regex:
- More robust with varied output formats
- Easier to debug
- Handles ANSI codes cleanly

### No Session ID in Resume

`:KiroResume` always resumes the last session (kiro-cli behavior). To resume a specific session, use `:KiroResumePicker` for interactive selection.

## Future Enhancements

Potential additions:
- Session metadata caching for performance
- Session search/filter in telescope
- Session rename functionality (if kiro-cli adds support)
- Session export (separate from conversation export)

## Status

✅ **Complete and Production Ready**

All acceptance criteria met:
- Commands work as specified
- Telescope integration functional
- Fallback support working
- All tests passing
- Documentation complete

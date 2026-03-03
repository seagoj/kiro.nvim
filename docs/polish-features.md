# Polish Features

## Summary

Added polish features including multi-file context support and terminal clear functionality.

## Features Added

### 1. Multiple File Context

**Send multiple files in one request:**
```lua
local kiro = require('kiro')

kiro.send_with_files('Explain these files', {
  'lua/kiro/init.lua',
  'lua/kiro/config.lua',
  'lua/kiro/terminal/init.lua',
})
```

**Use cases:**
- Compare multiple files
- Explain related modules
- Refactor across files
- Review pull requests

**Implementation:**
- `build_multi_file_context()` - Validates and builds context
- `send_with_files()` - Public API function
- File validation for all files
- Clear error messages

### 2. Clear Terminal

**Clear terminal and history:**
```lua
local kiro = require('kiro')

-- Close terminal and clear history
kiro.clear_terminal()
```

**Difference from close_terminal:**
- `close_terminal()` - Just closes the window
- `clear_terminal()` - Closes window AND clears history

**Use cases:**
- Start fresh conversation
- Clean up after session
- Reset state completely

## API Reference

### send_with_files(prompt, files)

Send message with multiple files as context.

**Parameters:**
- `prompt` (string) - Prompt text
- `files` (table) - List of file paths

**Example:**
```lua
kiro.send_with_files('Review these modules', {
  'lua/kiro/init.lua',
  'lua/kiro/config.lua',
})
```

**Validation:**
- All files must exist
- All files must be readable
- Returns error if any file invalid

### clear_terminal()

Clear terminal window and command history.

**Example:**
```lua
-- Start fresh
kiro.clear_terminal()
```

**Behavior:**
- Closes terminal window
- Clears command history
- Logs action in debug mode

## Testing

Added 4 new tests:
- ✅ Exposes clear_terminal function
- ✅ Exposes send_with_files function
- ✅ Sends with multiple files
- ✅ Validates files in multi-file context

Total tests: 57 → 61 (+7%)

## Usage Examples

### Compare Files

```lua
kiro.send_with_files('What are the differences between these files?', {
  'old_version.lua',
  'new_version.lua',
})
```

### Explain Module Structure

```lua
kiro.send_with_files('Explain how these modules work together', {
  'lua/kiro/init.lua',
  'lua/kiro/terminal/init.lua',
  'lua/kiro/commands.lua',
})
```

### Review Related Files

```lua
kiro.send_with_files('Review this feature implementation', {
  'lua/kiro/history.lua',
  'tests/history_spec.lua',
  'docs/command-history.md',
})
```

### Clean Slate

```lua
-- After a long session, start fresh
kiro.clear_terminal()

-- Now send new query
kiro.send_with_files('New topic', { 'file.lua' })
```

## Implementation Details

### Multi-File Context Format

Files are formatted as:
```
(file: path/to/file1.lua) (file: path/to/file2.lua)
```

This allows Kiro to understand multiple file contexts.

### Validation

All files validated before sending:
1. Check file exists
2. Check file is readable
3. Return error if any fail
4. Build context only if all valid

### Error Handling

Clear error messages:
```lua
-- Invalid file
kiro.send_with_files('Test', { '/nonexistent.lua' })
-- Error: File not readable: /nonexistent.lua
```

## Benefits

### For Users
- Send multiple files in one request
- Compare and analyze related code
- Review features across files
- Clean slate with clear_terminal

### For Workflows
- Code reviews with context
- Refactoring across modules
- Feature explanations
- Architecture discussions

## Debug Logging

With `debug = true`:
```
[Kiro Debug] Sending with 3 files
[Kiro Debug] Building context for 3 files
[Kiro Debug] Sending message: Explain these files (file: ...) (file: ...) (file: ...)
[Kiro Debug] Clearing terminal
[Kiro Debug] History cleared
```

## Comparison

### Before
```lua
-- Had to send files one at a time
kiro.send_with_files('Explain', { 'file1.lua' })
-- Wait for response...
kiro.send_with_files('And this', { 'file2.lua' })
-- Wait for response...
```

### After
```lua
-- Send all at once
kiro.send_with_files('Explain these files', {
  'file1.lua',
  'file2.lua',
  'file3.lua',
})
```

## Future Enhancements

Potential additions:
- Glob pattern support (`*.lua`)
- Directory support (all files in dir)
- File content preview
- Max file size limits
- Binary file detection

## User Impact

**Before:**
- Single file context only
- No way to clear history with terminal
- Manual file-by-file queries

**After:**
- Multi-file context support
- Clear terminal and history together
- Efficient multi-file queries
- Better workflow for related files

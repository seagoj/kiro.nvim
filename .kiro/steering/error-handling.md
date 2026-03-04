# Error Handling Improvements

## Overview

Enhanced error handling throughout the plugin to provide better feedback and graceful failure recovery.

## Changes Made

### 1. File Validation (`lua/kiro/commands.lua`)

**Before:** No validation of file paths or line ranges
**After:** 
- Validates file exists and is readable
- Validates line ranges are within file bounds
- Returns descriptive error messages

```lua
-- Now catches:
- Empty buffers (no file)
- Unreadable files
- Invalid line ranges
```

### 2. Terminal Operations (`lua/kiro/terminal/init.lua`)

**Before:** Silent failures, no error propagation
**After:**
- Returns `(success, error)` tuple
- Checks kiro-cli availability before operations
- Provides fallback when reusing terminal fails

### 3. Window Management (`lua/kiro/terminal/window.lua`)

**Before:** Unchecked API calls that could fail silently
**After:**
- Validates buffer and channel state
- Wraps API calls in `pcall` for error capture
- Returns detailed error messages

```lua
-- Now catches:
- Invalid terminal buffers
- Unavailable channels
- Failed terminal creation
- Failed message sending
```

### 4. Command Registration (`lua/kiro/commands.lua`)

**Before:** Errors not surfaced to user
**After:**
- Propagates errors from file validation
- Propagates errors from terminal operations
- Shows user-friendly notifications

## Error Messages

All error messages now follow consistent patterns:

- **File errors**: "File not readable: {path}"
- **Range errors**: "Invalid line range: {start}-{end} (file has {count} lines)"
- **Terminal errors**: "Failed to create terminal: {reason}"
- **Channel errors**: "Terminal channel is not available"
- **CLI errors**: "kiro-cli not found in PATH"

## Testing

Added test coverage for error scenarios:
- Missing kiro-cli executable
- Invalid file paths
- Invalid line ranges
- Terminal creation failures

Run tests with: `./scripts/test.sh`

## User Impact

Users now receive:
1. Clear error messages explaining what went wrong
2. Actionable feedback (e.g., "Install from https://kiro.ai")
3. Graceful degradation (fallback to new terminal if reuse fails)
4. No silent failures or mysterious behavior

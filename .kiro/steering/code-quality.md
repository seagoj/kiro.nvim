# Code Quality Improvements

## Summary

Improved code quality with complete type annotations, centralized constants, and a proper logging system.

## Changes Made

### 1. Constants Module (`lua/kiro/constants.lua`)

**Centralized all magic strings and values:**
- Log levels
- Split commands
- Default keymaps
- User-facing messages
- Validation limits
- CLI command strings

**Benefits:**
- Single source of truth for all constants
- Easy to update messages
- No scattered magic strings
- Better maintainability

**Example:**
```lua
local Constants = require("kiro.constants")

-- Before
if vim.fn.executable("kiro-cli") == 0 then
  return false, "kiro-cli not found in PATH"
end

-- After
if vim.fn.executable(Constants.CLI.EXECUTABLE) == 0 then
  return false, Constants.MESSAGES.KIRO_CLI_NOT_FOUND
end
```

### 2. Logging System (`lua/kiro/logger.lua`)

**Structured logging with levels:**
- `Logger.debug()` - Debug information (only when enabled)
- `Logger.info()` - Informational messages
- `Logger.warn()` - Warnings
- `Logger.error()` - Errors

**Features:**
- Enable/disable logging
- Configurable log level
- Automatic formatting
- Consistent prefix for debug messages

**Usage:**
```lua
local Logger = require("kiro.logger")

-- Enable debug logging
Logger.enable(Constants.LOG_LEVELS.DEBUG)

-- Log messages
Logger.debug("Creating terminal with command: %s", command)
Logger.info("Message sent")
Logger.warn("Failed to reuse terminal")
Logger.error("Invalid config: %s", err)
```

**Integration with config:**
```lua
require('kiro').setup({
  debug = true,  -- Enables debug logging
})
```

### 3. Complete Type Annotations

**Added comprehensive LuaLS annotations:**

```lua
--- @class KiroConfigOptions
--- @field commands table<string, string|function>|nil
--- @field split string|nil
--- @field terminal_size number|nil
--- @field profile string|nil
--- ... (all fields documented)

--- @class WindowState
--- @field bufnr number|nil
--- @field winid number|nil
--- @field last_message string|nil

--- @param opts KiroConfigOptions|nil
--- @return KiroConfigOptions config
--- @return string|nil err
function M.init(opts)
```

**Benefits:**
- Better IDE autocomplete
- Type checking with LuaLS
- Self-documenting code
- Catch errors earlier

### 4. Consistent Error Handling

**All error messages now use constants:**
- Consistent wording across codebase
- Easy to update all occurrences
- Translatable (if needed in future)

**Before:**
```lua
return nil, "No file in current buffer"
return nil, string.format("File not readable: %s", file)
return false, "kiro-cli not found in PATH"
```

**After:**
```lua
return nil, Constants.MESSAGES.NO_FILE
return nil, string.format(Constants.MESSAGES.FILE_NOT_READABLE, file)
return false, Constants.MESSAGES.KIRO_CLI_NOT_FOUND
```

## Files Modified

| File | Changes |
|------|---------|
| `lua/kiro/constants.lua` | **NEW** - All constants |
| `lua/kiro/logger.lua` | **NEW** - Logging system |
| `lua/kiro/config.lua` | Type annotations, use constants |
| `lua/kiro/init.lua` | Type annotations, use logger |
| `lua/kiro/commands.lua` | Use logger and constants |
| `lua/kiro/terminal/init.lua` | Use logger and constants |
| `lua/kiro/terminal/shell.lua` | Use constants |
| `lua/kiro/terminal/window.lua` | Type annotations, logger, constants |

## Testing

All 43 tests pass ✅

No functional changes - purely code quality improvements.

## Developer Experience

**Before:**
- Magic strings scattered throughout
- Inconsistent error messages
- No debug logging
- Minimal type information

**After:**
- Centralized constants
- Consistent, maintainable messages
- Structured debug logging
- Complete type annotations
- Better IDE support
- Easier to maintain and extend

## Debug Mode Example

```lua
require('kiro').setup({
  debug = true,
})

-- Now see debug output:
-- [Kiro Debug] Configuration: { ... }
-- [Kiro Debug] Registering command: KiroBuffer
-- [Kiro Debug] Executing command: KiroBuffer
-- [Kiro Debug] Building context for file.lua
-- [Kiro Debug] Sending message: (file: file.lua)
-- [Kiro Debug] Creating terminal with command: kiro-cli chat '...'
-- [Kiro Debug] Terminal created: bufnr=5, winid=1001
-- [Kiro Debug] Keymap registered: <C-q> -> close
-- [Kiro Debug] Keymap registered: <C-r> -> resend
```

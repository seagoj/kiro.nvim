# Error Handling Standardization

## Summary

Implemented standardized error handling across the kiro.nvim codebase using a consistent `ErrorResult` pattern. This replaces the previous mixed approach of `(boolean, error)` tuples and `pcall` usage.

## Changes

### New Module: `lua/kiro/error.lua`

Created a centralized error handling module with:

- **ErrorResult type**: Consistent return type with `ok`, `value`, `error`, and `code` fields
- **Error codes**: Programmatic error identification (e.g., `NO_FILE`, `CLI_NOT_FOUND`)
- **Helper functions**:
  - `Error.ok(value)` - Create success result
  - `Error.err(message, code)` - Create error result
  - `Error.wrap(fn, message, code)` - Wrap pcall with error handling
  - `Error.is_ok(result)` / `Error.is_err(result)` - Check result status
  - `Error.unwrap_or(result, default)` - Safe value extraction

### Updated Modules

**lua/kiro/config.lua**
- `Config.init()` now returns `ErrorResult` instead of `(config, error)`

**lua/kiro/commands.lua**
- `build_file_context()` returns `ErrorResult`
- `build_multi_file_context()` returns `ErrorResult`
- `send_with_files()` returns `ErrorResult`

**lua/kiro/terminal/init.lua**
- `Terminal.open()` returns `ErrorResult`

**lua/kiro/terminal/window.lua**
- `Window.send_message()` returns `ErrorResult`
- `Window.create()` returns `ErrorResult`

**lua/kiro/terminal/toggleterm.lua**
- `Toggleterm.open()` returns `ErrorResult`

**lua/kiro/init.lua**
- Updated all error handling to use `ErrorResult` pattern

### Test Updates

All test files updated to work with the new `ErrorResult` pattern:
- `tests/config_spec.lua`
- `tests/integration_spec.lua`
- `tests/commands_spec.lua`
- `tests/kiro_spec.lua`

## Benefits

1. **Consistency**: All functions use the same error handling pattern
2. **Type Safety**: Better type annotations with `@return ErrorResult`
3. **Error Codes**: Programmatic error handling with standardized codes
4. **Clarity**: Explicit `Error.is_ok()` / `Error.is_err()` checks
5. **Maintainability**: Centralized error handling logic

## Migration Guide

### Before
```lua
local success, err = some_function()
if not success then
  handle_error(err)
end
```

### After
```lua
local result = some_function()
if Error.is_err(result) then
  handle_error(result.error)
end
-- Access value with result.value
```

## Error Codes

Available error codes in `Error.codes`:
- `NO_FILE` - No file open in buffer
- `FILE_NOT_READABLE` - File cannot be read
- `FILE_TOO_LARGE` - File exceeds size limit
- `INVALID_RANGE` - Invalid line range
- `TERMINAL_INVALID` - Terminal buffer invalid
- `CHANNEL_UNAVAILABLE` - Terminal channel unavailable
- `SEND_FAILED` - Failed to send message
- `CREATE_FAILED` - Failed to create terminal
- `CLI_NOT_FOUND` - kiro-cli not found
- `CONFIG_INVALID` - Invalid configuration
- `LSP_PARSE_FAILED` - LSP config parse error

## Testing

All 57 tests pass with the new error handling system.

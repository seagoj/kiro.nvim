# Error Message Redundancy Fix

## Problem

When `KiroBuffer` is invoked without an open file in the buffer, two error messages appeared:
1. "No file in current buffer" (from `build_file_context`)
2. "Cannot add empty or non-string message to history" (from `History.add`)

The second error was redundant and confusing.

## Root Cause

In `lua/kiro/commands.lua`, the `register()` function continued execution even after a NO_FILE error:

```lua
local result = build_file_context(opts)
local context = ""

if Error.is_err(result) then
  Logger.error(result.error, { notify = true })
else
  context = result.value
end

-- Execution continued with empty context
local message = prompt == "" and context or prompt .. " " .. context
terminal.open(message, config)  -- Empty message sent
```

This caused:
1. NO_FILE error logged
2. Empty `context` used
3. Empty or whitespace-only `message` created
4. Empty message sent to terminal
5. History tried to add empty message → second error

## Solution

Return early when `build_file_context()` fails:

```lua
local result = build_file_context(opts)

if Error.is_err(result) then
  Logger.error(result.error, { notify = true })
  return  -- Stop here
end

local context = result.value
-- Continue only with valid context
```

## Changes Made

### 1. Early Return (`lua/kiro/commands.lua`)

Modified `M.register()` to return immediately on error:

```lua
function M.register(name, prompt, terminal, config)
  vim.api.nvim_create_user_command(name, function(opts)
    Logger.debug("Executing command: %s", name)
    local result = build_file_context(opts)
    
    if Error.is_err(result) then
      Logger.error(result.error, { notify = true })
      return  -- Early return prevents further execution
    end
    
    local context = result.value
    -- ... rest of function
  end, { range = true })
end
```

### 2. Test Enhancement (`tests/commands_spec.lua`)

Added verification that history error doesn't appear:

```lua
it("handles missing file error", function()
  -- ... setup
  
  local history_error_called = false
  notify_stub.invokes(function(msg, level)
    if msg:match("Cannot add empty") then
      history_error_called = true
    end
  end)
  
  vim.cmd("TestCommand")
  assert.is_false(history_error_called) -- Verify no redundant error
end)
```

## Behavior

### Before
```
User runs :KiroBuffer with no file open
  ↓
Error: "No file in current buffer"
  ↓
Execution continues with empty context
  ↓
Empty message sent to terminal
  ↓
Error: "Cannot add empty or non-string message to history"
```

### After
```
User runs :KiroBuffer with no file open
  ↓
Error: "No file in current buffer"
  ↓
Execution stops (early return)
  ↓
No further errors
```

## Impact

### User Experience
- ✅ Single, clear error message
- ✅ No confusing redundant errors
- ✅ Immediate feedback

### Code Quality
- ✅ Fail-fast pattern
- ✅ Prevents invalid state
- ✅ Cleaner error handling

## Testing

All tests pass:
```
Total Tests: 64
Success: 64
Failed:  0
Errors:  0
```

Specific test verifies:
- ✅ NO_FILE error is shown
- ✅ History error is NOT shown
- ✅ Execution stops after first error

## Related Errors

This pattern applies to all errors in `build_file_context()`:
- NO_FILE
- FILE_NOT_READABLE
- FILE_TOO_LARGE
- INVALID_RANGE

All now stop execution immediately, preventing cascading errors.

## Status

✅ **Complete**

The redundant error message has been eliminated with a simple early return.

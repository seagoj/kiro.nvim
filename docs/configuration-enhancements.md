# Configuration Enhancements

## Summary

Added terminal size control and kiro-cli profile support for better customization.

## Features Added

### 1. Terminal Size Control

**Configure split dimensions:**
```lua
-- Vertical split with specific width
require('kiro').setup({
  split = 'vsplit',
  terminal_size = 80,  -- 80 columns wide
})

-- Horizontal split with specific height
require('kiro').setup({
  split = 'split',
  terminal_size = 20,  -- 20 lines tall
})
```

**Behavior:**
- If not set, uses Neovim's default split size
- Validated to be between 1 and 999
- Applied when creating new terminal windows

### 2. Profile Support

**Use different kiro-cli profiles:**
```lua
require('kiro').setup({
  profile = 'work',  -- Uses: kiro-cli chat --profile work
})
```

**Use cases:**
- Different profiles for work vs personal projects
- Project-specific configurations
- Team-specific settings

**Implementation:**
- Passes `--profile <name>` to kiro-cli
- Validated to be a string
- Optional (defaults to kiro-cli's default profile)

## Configuration Options

All new options added to config:

```lua
require('kiro').setup({
  -- Existing options
  split = 'vsplit',
  reuse_terminal = true,
  auto_insert_mode = true,
  keymaps = {
    close = "<C-q>",
    resend = "<C-r>",
  },
  
  -- New options
  terminal_size = 80,      -- Optional: split size
  profile = 'work',        -- Optional: kiro-cli profile
})
```

## Validation

Both options are validated:
- `terminal_size` must be a number between 1 and 999
- `profile` must be a string
- Invalid values show clear error messages

## Testing

Added 3 new tests:
- ✅ Validates terminal_size option
- ✅ Validates profile option
- ✅ Includes profile in build_command

Total tests: 43 (all passing)

## Examples

### Large vertical split for detailed responses
```lua
require('kiro').setup({
  split = 'vsplit',
  terminal_size = 120,
})
```

### Small horizontal split for quick queries
```lua
require('kiro').setup({
  split = 'split',
  terminal_size = 15,
})
```

### Work profile with custom size
```lua
require('kiro').setup({
  profile = 'work',
  split = 'vsplit',
  terminal_size = 100,
})
```

## User Impact

**Before:**
- Terminal size determined by Neovim defaults
- No way to use different kiro-cli profiles
- One-size-fits-all configuration

**After:**
- Precise control over terminal dimensions
- Support for multiple profiles/contexts
- Flexible configuration per use case

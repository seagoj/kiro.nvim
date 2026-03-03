# User Experience Improvements

## Summary

Enhanced user experience with visual feedback, buffer-local keymaps, and better terminal management.

## Features Added

### 1. Buffer-Local Keymaps

**Default keymaps in terminal buffer (normal mode):**
- `<C-q>` - Close the terminal
- `<C-r>` - Resend the last message

**Customizable via config:**
```lua
require('kiro').setup({
  keymaps = {
    close = "<leader>q",  -- Custom close keymap
    resend = "<leader>r", -- Custom resend keymap
  }
})
```

**Disable specific keymaps:**
```lua
require('kiro').setup({
  keymaps = {
    close = false,  -- Disable close keymap
    resend = "<C-r>",
  }
})
```

### 2. Visual Feedback

**Loading indicators:**
- Shows "Sending to Kiro..." when opening terminal
- Shows "Message sent" on successful send
- Shows warnings when falling back to new terminal

**Better error messages:**
- All errors now show clear, actionable messages
- Errors displayed via vim.notify with appropriate log levels

### 3. Message History

**Last message tracking:**
- Plugin remembers the last message sent
- Resend feature (`<C-r>`) reuses last message
- History cleared when terminal is closed

**Lua API:**
```lua
local kiro = require('kiro')

-- Close terminal
kiro.close_terminal()

-- Resend last message
kiro.resend()
```

### 4. Better Terminal Buffer Options

**Automatic buffer settings:**
- `buflisted = false` - Doesn't clutter buffer list
- `number = false` - No line numbers in terminal
- `relativenumber = false` - No relative line numbers

## Configuration

New `keymaps` option added to config:

```lua
require('kiro').setup({
  keymaps = {
    close = "<C-q>",   -- Close terminal keymap
    resend = "<C-r>",  -- Resend last message keymap
  }
})
```

## Testing

Added 4 new tests:
- ✅ Exposes close_terminal function
- ✅ Exposes resend function
- ✅ Validates keymaps option
- ✅ Tracks last message

Total tests: 40 (all passing)

## User Impact

**Before:**
- No way to close terminal from normal mode
- No way to resend messages
- No feedback when sending commands
- Terminal buffers cluttered buffer list

**After:**
- Quick close with `<C-q>`
- Quick resend with `<C-r>`
- Clear feedback for all operations
- Clean buffer list
- Customizable keymaps
- Lua API for advanced users

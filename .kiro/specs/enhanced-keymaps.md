# Enhanced Keymaps

## Problem

Limited keyboard shortcuts for common Kiro operations.

## Requirements

1. Additional useful keymaps
2. Configurable key bindings
3. Buffer-local to Kiro terminal
4. Discoverable (show in help)

## Acceptance Criteria

- [ ] Cancel current request
- [ ] Navigate history (previous/next)
- [ ] Clear terminal
- [ ] Export conversation
- [ ] All keymaps configurable
- [ ] All keymaps buffer-local

## Configuration

```lua
require('kiro').setup({
  keymaps = {
    close = '<C-q>',           -- Close terminal (existing)
    resend = '<C-r>',          -- Resend last message (existing)
    cancel = '<C-c>',          -- Cancel current request (new)
    history_prev = '<C-p>',    -- Previous in history (new)
    history_next = '<C-n>',    -- Next in history (new)
    clear = '<C-l>',           -- Clear terminal (new)
    export = '<C-e>',          -- Export conversation (new)
  },
})
```

## Keymaps

### Existing
- `<C-q>` - Close terminal
- `<C-r>` - Resend last message

### New
- `<C-c>` - Cancel current request (send interrupt signal)
- `<C-p>` - Navigate to previous message in history
- `<C-n>` - Navigate to next message in history
- `<C-l>` - Clear terminal buffer
- `<C-e>` - Export current conversation

## Implementation

### Cancel Request
Send interrupt signal to kiro-cli process:
```lua
vim.fn.jobstop(job_id)
```

### History Navigation
Use existing history module:
```lua
local prev = History.previous()
if prev then
  terminal.send_message(prev)
end
```

### Clear Terminal
Clear buffer content:
```lua
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
```

### Export
Call export function:
```lua
kiro.export_session()
```

## Discoverability

Show keymaps in:
- `:help kiro.nvim` documentation
- Startup message in terminal
- `:KiroKeymaps` command to list all

## Disable Keymaps

Set to `false` to disable:
```lua
keymaps = {
  cancel = false,  -- Disable cancel keymap
}
```

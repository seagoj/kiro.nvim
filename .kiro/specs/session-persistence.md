# Session Resume Integration

## Problem

Kiro CLI has built-in session persistence (`--resume`, `--resume-picker`, `--list-sessions`), but kiro.nvim doesn't expose these features. Users must exit Neovim to resume conversations.

## Requirements

1. Expose kiro-cli's `--resume` flag
2. Expose kiro-cli's `--resume-picker` flag
3. List available sessions
4. Delete sessions
5. Integrate with command palette

## Acceptance Criteria

- [ ] `:KiroResume` command to resume last conversation
- [ ] `:KiroResumePicker` command for interactive session selection
- [ ] `:KiroListSessions` command to list all sessions
- [ ] `:KiroDeleteSession <id>` command to delete a session
- [ ] Sessions appear in command palette (telescope/vim.ui.select)
- [ ] Keymap to quickly resume last session

## Configuration

```lua
require('kiro').setup({
  keymaps = {
    resume = '<leader>kr',  -- Quick resume last session
  },
})
```

## API

```lua
-- Resume last conversation
kiro.resume()

-- Open session picker
kiro.resume_picker()

-- List sessions (returns array of session info)
local sessions = kiro.list_sessions()

-- Delete session by ID
kiro.delete_session('session-id')
```

## Commands

```vim
:KiroResume              " Resume last conversation
:KiroResumePicker        " Pick session to resume
:KiroListSessions        " List all sessions
:KiroDeleteSession <id>  " Delete session by ID
```

## Implementation

### Resume Last Session
```lua
function M.resume()
  local cmd = Shell.build_command("", config, { resume = true })
  Terminal.open_with_command(cmd, config)
end
```

### Resume Picker
```lua
function M.resume_picker()
  local cmd = Shell.build_command("", config, { resume_picker = true })
  Terminal.open_with_command(cmd, config)
end
```

### List Sessions
```lua
function M.list_sessions()
  local output = vim.fn.system("kiro-cli chat --list-sessions")
  -- Parse and return session list
end
```

### Delete Session
```lua
function M.delete_session(id)
  vim.fn.system(string.format("kiro-cli chat --delete-session %s", id))
end
```

## Telescope Integration

Add to command palette:
```lua
-- lua/kiro/telescope/sessions.lua
-- Show sessions with metadata, resume on selection
```

## Session Display Format

```
Available Sessions:
  [abc123] 2026-03-04 14:30 - "Explain kiro.nvim code" (15 messages)
  [def456] 2026-03-03 09:15 - "Fix bug in terminal" (8 messages)
  [ghi789] 2026-03-02 16:45 - "Add new feature" (23 messages)
```

# Session Persistence

## Problem

Sessions are lost when Neovim is closed. Users lose conversation history and context when restarting.

## Requirements

1. Save conversation history to disk per session
2. Restore sessions on startup
3. Session metadata (timestamp, message count, last used)
4. Clean up old sessions automatically

## Acceptance Criteria

- [ ] Sessions saved to `.kiro/sessions/<name>.json`
- [ ] Auto-save on message send
- [ ] Restore last session on startup (optional)
- [ ] List available sessions
- [ ] Delete old sessions (configurable retention)
- [ ] Session includes: name, messages, timestamp, metadata

## Configuration

```lua
require('kiro').setup({
  session_persistence = true,  -- Enable persistence (default: false)
  session_retention_days = 30, -- Keep sessions for 30 days
  restore_last_session = false, -- Auto-restore on startup
})
```

## API

```lua
-- Save current session
kiro.save_session('session-name')

-- Load session
kiro.load_session('session-name')

-- List sessions
local sessions = kiro.list_saved_sessions()

-- Delete session
kiro.delete_session('session-name')
```

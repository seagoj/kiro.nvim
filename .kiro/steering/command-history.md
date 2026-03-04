# Command History Feature

## Summary

Added command history/recall functionality to track and reuse previous messages sent to Kiro.

## Features

### 1. Automatic History Tracking

**All messages automatically saved:**
- Messages added to history when sent
- Duplicate consecutive messages ignored
- Configurable maximum size (default: 50)

### 2. History Navigation

**Navigate through history:**
```lua
local History = require("kiro.history")

-- Go to previous message
local prev = History.previous()

-- Go to next message
local next = History.next()
```

### 3. History Management API

**Complete API for history:**
```lua
local kiro = require('kiro')

-- Get all history
local history = kiro.get_history()

-- Send from history by index
kiro.send_from_history(-1)  -- Most recent
kiro.send_from_history(1)   -- Oldest

-- Clear history
kiro.clear_history()
```

### 4. Configuration

**Customize history size:**
```lua
require('kiro').setup({
  history_size = 100,  -- Keep last 100 messages (default: 50)
})
```

## Implementation

### History Module (`lua/kiro/history.lua`)

**Core functionality:**
- `add(message)` - Add message to history
- `previous()` - Navigate to previous message
- `next()` - Navigate to next message
- `get_all()` - Get all history
- `clear()` - Clear history
- `size()` - Get history size
- `set_max_size(size)` - Set maximum size

**Features:**
- Circular navigation
- Duplicate detection
- Automatic trimming when max size exceeded
- Index tracking for navigation

### Integration

**Automatic tracking:**
- Messages added in `terminal.open()`
- History persists across terminal sessions
- Cleared only when explicitly requested

**Configuration:**
- `history_size` option in config
- Validated (must be >= 1)
- Applied during setup

## Usage Examples

### Basic History Access

```lua
local kiro = require('kiro')

-- View history
local history = kiro.get_history()
for i, msg in ipairs(history) do
  print(string.format("[%d] %s", i, msg))
end
```

### Send from History

```lua
-- Send most recent message
kiro.send_from_history(-1)

-- Send oldest message
kiro.send_from_history(1)

-- Send specific message
kiro.send_from_history(5)
```

### Clear History

```lua
-- Clear all history
kiro.clear_history()
```

### Custom History Size

```lua
require('kiro').setup({
  history_size = 200,  -- Keep more history
})
```

## Testing

Added 14 comprehensive tests:
- ✅ Starts empty
- ✅ Adds messages to history
- ✅ Does not add duplicate consecutive messages
- ✅ Allows duplicate non-consecutive messages
- ✅ Navigates to previous messages
- ✅ Stops at first message when going previous
- ✅ Navigates to next messages
- ✅ Returns nil when at end of history
- ✅ Returns nil for next when no navigation started
- ✅ Returns all history
- ✅ Clears history
- ✅ Respects max size
- ✅ Trims history when max size is reduced
- ✅ Resets navigation index when adding new message

Total tests: 43 → 57 (+14, 33% increase)

## Use Cases

### 1. Repeat Previous Query
```lua
-- Quickly resend last message
kiro.send_from_history(-1)
```

### 2. Review History
```lua
-- See what you've asked
local history = kiro.get_history()
vim.notify(vim.inspect(history))
```

### 3. Reuse Old Query
```lua
-- Send a message from earlier in the session
kiro.send_from_history(3)
```

### 4. Clean Up
```lua
-- Clear history at end of session
kiro.clear_history()
```

## Benefits

### For Users
- Don't retype similar queries
- Review what you've asked
- Quickly iterate on prompts
- Persistent across terminal sessions

### For Workflows
- Experiment with variations
- Reuse successful prompts
- Track conversation flow
- Quick access to recent queries

## Configuration Options

```lua
require('kiro').setup({
  history_size = 50,  -- Maximum messages to keep
  debug = true,       -- See history operations in logs
})
```

## Debug Logging

With `debug = true`, see history operations:
```
[Kiro Debug] Added to history (total: 5)
[Kiro Debug] Sending from history [3]: Explain the code in (file: test.lua)
[Kiro Debug] History cleared
```

## API Reference

### Main API

| Function | Description |
|----------|-------------|
| `get_history()` | Get all history as array |
| `clear_history()` | Clear all history |
| `send_from_history(index)` | Send message by index |

### History Module

| Function | Description |
|----------|-------------|
| `add(message)` | Add message to history |
| `previous()` | Get previous message |
| `next()` | Get next message |
| `get_all()` | Get all messages |
| `clear()` | Clear history |
| `size()` | Get history size |
| `set_max_size(size)` | Set max size |

## Future Enhancements

Potential additions:
- Persistent history (save to file)
- Search history
- History UI/picker
- Export history
- History statistics

## User Impact

**Before:**
- No way to reuse previous messages
- Had to retype similar queries
- No record of what was asked

**After:**
- Automatic history tracking
- Easy access to previous messages
- Send from history by index
- Configurable history size
- Complete API for history management

# Conversation Export

## Problem

Users want to save conversations for reference, sharing, or documentation.

## Requirements

1. Export current session to file
2. Format as markdown
3. Include timestamps
4. Include metadata (session name, date, message count)

## Acceptance Criteria

- [ ] Export to markdown format
- [ ] Include all messages in session
- [ ] Timestamp for each message
- [ ] Metadata header
- [ ] Configurable output location
- [ ] Option to export all sessions

## Configuration

```lua
require('kiro').setup({
  export_dir = '~/.kiro/exports',  -- Export location
  export_format = 'markdown',      -- 'markdown', 'text', 'json'
  include_timestamps = true,       -- Include timestamps
})
```

## API

```lua
-- Export current session
kiro.export_session('output.md')

-- Export specific session
kiro.export_session('output.md', 'session-name')

-- Export all sessions
kiro.export_all_sessions('exports/')
```

## Commands

```vim
:KiroExport [filename]           " Export current session
:KiroExportSession name [file]   " Export specific session
:KiroExportAll [directory]       " Export all sessions
```

## Markdown Format

```markdown
# Kiro Conversation: default
**Date:** 2026-03-04  
**Messages:** 15  
**Duration:** 45 minutes

---

## Message 1
**Time:** 14:30:15  
**User:**
Explain this code (file: lua/kiro/init.lua)

**Kiro:**
This code implements...

---

## Message 2
**Time:** 14:32:45  
**User:**
How can I improve it?

**Kiro:**
You could improve it by...

---
```

## JSON Format

```json
{
  "session": "default",
  "date": "2026-03-04",
  "messages": [
    {
      "timestamp": "14:30:15",
      "user": "Explain this code",
      "response": "This code implements..."
    }
  ]
}
```

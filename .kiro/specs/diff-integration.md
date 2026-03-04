# Diff Integration

## Problem

When Kiro suggests code changes, users must manually copy and apply them.

## Requirements

1. Parse code blocks from Kiro responses
2. Show diff view comparing current vs suggested
3. Apply changes to buffer interactively
4. Accept/reject individual changes

## Acceptance Criteria

- [ ] Detect code blocks in responses
- [ ] Match code blocks to open buffers
- [ ] Show diff view (vimdiff or similar)
- [ ] Apply changes with confirmation
- [ ] Undo/redo support
- [ ] Handle multiple code blocks in one response

## Configuration

```lua
require('kiro').setup({
  diff_integration = true,      -- Enable diff (default: false)
  diff_tool = 'vimdiff',        -- 'vimdiff', 'diffview', 'custom'
  auto_detect_changes = true,   -- Auto-detect code blocks
})
```

## Workflow

1. Kiro responds with code block
2. Plugin detects code block with file context
3. Show notification: "Code changes detected. View diff? [y/n]"
4. If yes, open diff view
5. User reviews changes
6. Accept (apply to buffer) or Reject (discard)

## Code Block Detection

Look for patterns:
```
```lua
-- lua/kiro/init.lua
function M.setup()
  -- changes here
end
```
```

Or explicit file markers:
```
File: lua/kiro/init.lua
```lua
-- code here
```
```

## Commands

```vim
:KiroDiff          " Show diff for last response
:KiroApply         " Apply suggested changes
:KiroReject        " Reject suggested changes
:KiroShowChanges   " List all detected changes
```

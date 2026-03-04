# File Preview for Multi-File Context

## Problem

When using glob patterns, users don't know which files will be sent before sending.

## Requirements

1. Show list of matched files before sending
2. Display total size
3. Allow confirmation or cancellation
4. Option to exclude specific files

## Acceptance Criteria

- [ ] Preview shows matched files from glob patterns
- [ ] Display file count and total size
- [ ] Confirm prompt before sending
- [ ] Option to exclude files from list
- [ ] Show which patterns matched which files
- [ ] Configurable auto-confirm threshold

## Configuration

```lua
require('kiro').setup({
  preview_files = true,           -- Show preview (default: true)
  auto_confirm_threshold = 5,     -- Auto-send if <= 5 files
  preview_format = 'detailed',    -- 'simple', 'detailed'
})
```

## Preview Format

**Simple:**
```
3 files matched (12.5 KB):
  lua/kiro/init.lua
  lua/kiro/config.lua
  lua/kiro/commands.lua

Send? [y/n]
```

**Detailed:**
```
Pattern: lua/**/*.lua
  ✓ lua/kiro/init.lua (8.2 KB)
  ✓ lua/kiro/config.lua (3.1 KB)
  ✓ lua/kiro/commands.lua (1.2 KB)

Total: 3 files (12.5 KB)

Send? [y/n/e] (e=exclude)
```

## Interactive Exclude

If user chooses 'e':
```
Select files to exclude (space to toggle, enter to confirm):
  [x] lua/kiro/init.lua
  [ ] lua/kiro/config.lua
  [x] lua/kiro/commands.lua
```

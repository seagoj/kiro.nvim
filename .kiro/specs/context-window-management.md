# Context Window Management

## Problem

Large files or many files can exceed context limits, causing errors or truncated context.

## Requirements

1. Estimate token count for context
2. Warn when approaching limits
3. Auto-truncate with user notification
4. Prioritize relevant sections (cursor position, selection)

## Acceptance Criteria

- [ ] Token estimation for files
- [ ] Warning at 80% of limit
- [ ] Auto-truncate at 100% with notification
- [ ] Prioritize cursor area when truncating
- [ ] Show context size before sending
- [ ] Configurable limits

## Configuration

```lua
require('kiro').setup({
  max_context_tokens = 100000,  -- Token limit (default: 100k)
  warn_threshold = 0.8,          -- Warn at 80%
  auto_truncate = true,          -- Auto-truncate (default: true)
  truncate_strategy = 'cursor',  -- 'cursor', 'selection', 'start', 'end'
})
```

## API

```lua
-- Estimate context size
local tokens = kiro.estimate_context_size({ 'file1.lua', 'file2.lua' })

-- Check if context fits
local fits, size = kiro.check_context_limit({ 'file1.lua' })
```

## Token Estimation

Use simple heuristic:
- 1 token ≈ 4 characters
- Count total characters / 4
- Add overhead for formatting

## Truncation Strategy

**cursor**: Keep lines around cursor position  
**selection**: Keep visual selection area  
**start**: Keep beginning of file  
**end**: Keep end of file

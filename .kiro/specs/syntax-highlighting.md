# Syntax Highlighting for Responses

## Problem

Code blocks in Kiro's terminal responses have no syntax highlighting, making them harder to read.

## Requirements

1. Detect markdown code fences in terminal output
2. Apply treesitter syntax highlighting to code blocks
3. Support multiple languages
4. Configurable enable/disable

## Acceptance Criteria

- [ ] Detect ` ```language ` code fences
- [ ] Apply treesitter highlighting for detected language
- [ ] Support common languages (lua, python, javascript, etc.)
- [ ] Fallback to no highlighting if language not supported
- [ ] Option to disable highlighting
- [ ] Works with all terminal backends (default, toggleterm)

## Configuration

```lua
require('kiro').setup({
  syntax_highlighting = true,  -- Enable highlighting (default: true)
  highlight_languages = {      -- Supported languages (default: all)
    'lua', 'python', 'javascript', 'typescript', 'rust', 'go'
  },
})
```

## Technical Approach

1. Monitor terminal buffer for new content
2. Parse for code fence patterns
3. Apply treesitter highlighting to code block regions
4. Update highlighting as content streams in

## Challenges

- Terminal buffers are special (not normal text buffers)
- Content streams in real-time
- Need to handle partial code blocks
- Performance with large responses

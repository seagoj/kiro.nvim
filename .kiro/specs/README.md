# Kiro.nvim Specifications

This directory contains specifications for features and improvements to kiro.nvim.

## Status

### ✅ Completed
- `error-message-redundancy.md` - Fixed redundant error messages

### 📋 Proposed
- `session-persistence.md` - Save/restore sessions across restarts
- `syntax-highlighting.md` - Syntax highlighting for code blocks in responses
- `context-window-management.md` - Smart handling of large contexts
- `file-preview.md` - Preview files before sending with glob patterns
- `diff-integration.md` - Interactive code change application
- `command-palette.md` - Telescope/fzf integration for browsing
- `configuration-profiles.md` - Multiple named configuration sets
- `conversation-export.md` - Export conversations to markdown/JSON
- `enhanced-keymaps.md` - Additional keyboard shortcuts

## Priority

**High Priority:**
1. session-persistence.md
2. syntax-highlighting.md
3. diff-integration.md

**Medium Priority:**
4. context-window-management.md
5. file-preview.md
6. command-palette.md

**Low Priority:**
7. configuration-profiles.md
8. conversation-export.md
9. enhanced-keymaps.md

## Format

Each spec includes:
- **Problem** - What issue does this solve?
- **Requirements** - What must be implemented?
- **Acceptance Criteria** - How do we know it's done?
- **Configuration** - How do users configure it?
- **API** - What functions/commands are exposed?

## Contributing

When implementing a spec:
1. Create a branch for the feature
2. Implement according to acceptance criteria
3. Add tests
4. Update documentation
5. Move spec to completed section
6. Create steering doc in `.kiro/steering/`

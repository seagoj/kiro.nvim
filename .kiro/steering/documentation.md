# Documentation Improvements

## Summary

Added comprehensive documentation including Vim help files, health check documentation, and troubleshooting guide.

## What Was Added

### 1. Vim Help Documentation (`doc/kiro.txt`)

**Standard Neovim help file accessible via `:help kiro.nvim`**

Sections:
- Introduction and requirements
- Configuration options with descriptions
- Commands and usage
- Keymaps
- Lua API reference
- Health check instructions

**Usage:**
```vim
:help kiro.nvim
:help kiro-configuration
:help kiro-commands
:help kiro-api
:help kiro.setup()
```

### 2. Health Check Documentation

**Added to both README and help file**

Run health check:
```vim
:checkhealth kiro
```

Verifies:
- kiro-cli is installed and in PATH

### 3. Troubleshooting Guide (README)

**Comprehensive troubleshooting section covering common issues:**

1. **kiro-cli not found**
   - Installation instructions
   - PATH verification
   - Restart requirements

2. **Terminal doesn't open**
   - Health check verification
   - Debug mode enablement
   - Message checking
   - Buffer validation

3. **Keymaps not working**
   - Mode verification
   - Buffer verification
   - Configuration checking
   - Keymap testing

4. **File context not included**
   - File validation
   - Readability checks
   - Debug mode usage
   - Visual selection tips

5. **Messages not sending**
   - CLI verification
   - Terminal buffer inspection
   - Reuse configuration
   - Debug logging

6. **Getting help**
   - Links to documentation
   - Issue tracker
   - Debug mode instructions

## Directory Structure

```
kiro.nvim/
├── doc/              # Vim help files (`:help kiro.nvim`)
│   └── kiro.txt
└── docs/             # Development documentation (markdown)
    ├── error-handling.md
    ├── test-coverage.md
    ├── user-experience.md
    ├── configuration-enhancements.md
    └── code-quality.md
```

**Purpose:**
- `doc/` - User-facing Vim help (standard Neovim convention)
- `docs/` - Development/improvement documentation

## Benefits

### For Users

1. **Integrated help system**
   - Access documentation without leaving Neovim
   - Standard `:help` interface
   - Searchable with tags

2. **Quick troubleshooting**
   - Common problems documented
   - Step-by-step solutions
   - Debug mode instructions

3. **Health check**
   - Easy verification of setup
   - Clear error messages
   - Installation guidance

### For Developers

1. **Comprehensive API docs**
   - All functions documented
   - Parameter descriptions
   - Usage examples

2. **Improvement tracking**
   - Separate docs for each enhancement
   - Clear before/after comparisons
   - Testing documentation

## Examples

### Using Help System

```vim
" Open main help
:help kiro.nvim

" Jump to specific sections
:help kiro-configuration
:help kiro.setup()
:help kiro-keymaps

" Search help
:helpgrep terminal
```

### Troubleshooting Workflow

1. Issue occurs
2. Check `:help kiro-troubleshooting` or README
3. Run `:checkhealth kiro`
4. Enable debug mode if needed
5. Check `:messages` for details

### Debug Mode

```lua
require('kiro').setup({
  debug = true,
})

-- Now see detailed logs:
-- [Kiro Debug] Configuration: { ... }
-- [Kiro Debug] Executing command: KiroBuffer
-- [Kiro Debug] Building context for file.lua
-- [Kiro Debug] Creating terminal with command: ...
```

## Testing

Verified:
- Help file syntax is valid
- All help tags work
- Links between sections function
- Examples are accurate

## User Impact

**Before:**
- No integrated help documentation
- Troubleshooting scattered or missing
- No health check documentation
- Users had to read source code

**After:**
- Complete `:help kiro.nvim` documentation
- Comprehensive troubleshooting guide
- Health check documented
- Clear examples and solutions
- Professional documentation standard

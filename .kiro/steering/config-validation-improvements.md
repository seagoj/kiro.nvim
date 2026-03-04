# Configuration Validation Improvements

## Summary

Enhanced configuration validation with detailed error messages, suggestions, per-project config support, and migration helpers for future config changes.

## Changes

### 1. Enhanced Validation (`lua/kiro/config.lua`)

**Better Error Messages**
- Detailed validation errors with context
- Actionable suggestions for fixing issues
- Range validation with min/max values
- Type checking with expected types

**Before:**
```
Error: terminal_size must be a number
```

**After:**
```
Error: terminal_size must be between 10 and 200 (got 5)
  Suggestion: Try a value between 10 and 200
```

**Validation Improvements:**
- Boolean options: Clear true/false suggestions
- Split option: Lists all valid values
- Terminal size: Shows valid range
- Float options: Validates percentage values (0-1)
- History size: Minimum value validation
- Unknown options: Detected and reported

### 2. Project-Specific Configuration

**Load `.kiro.lua` from project root**
```lua
-- .kiro.lua in project root
return {
  split = "float",
  profile = "work",
  commands = {
    KiroReview = "Review this code in",
  },
}
```

**Automatic Merging**
- Global config from Neovim setup
- Project config from `.kiro.lua`
- Project config takes precedence
- Graceful fallback if no project config

**API:**
```lua
-- Load project config
local config, err = Config.load_project_config("/path/to/project")

-- Merge with global config
local merged, err = Config.merge_with_project(global_opts, project_root)
```

### 3. Migration Helper (`lua/kiro/migrate.lua`)

**Future-Proof Configuration**
- Detect deprecated options
- Auto-migrate old configs
- Validate against schema
- Generate migration reports

**API:**
```lua
local Migrate = require("kiro.migrate")

-- Check for deprecated options
local warnings = Migrate.check_deprecated(config)

-- Migrate configuration
local migrated, changes = Migrate.migrate(config)

-- Validate schema
local valid, issues = Migrate.validate_schema(config)

-- Generate report
local report = Migrate.report(config)
```

### 4. New Commands

**`:KiroCheckConfig`**
- Validates current configuration
- Reports unknown options
- Shows suggestions for fixes

```vim
:KiroCheckConfig
" Output: ✓ Configuration is valid
" Or: Configuration Issues with suggestions
```

## Usage Examples

### Project Configuration

**1. Create `.kiro.lua` in project root:**
```lua
return {
  split = "float",
  float_opts = { width = 0.9, height = 0.9 },
  profile = "work",
  commands = {
    KiroReview = "Review this code in",
    KiroTest = "Generate tests for",
  },
}
```

**2. Global config in `init.lua`:**
```lua
require('kiro').setup({
  split = "vsplit",  -- Default for all projects
  debug = false,
})
```

**3. Project config overrides global:**
- Project uses `float` split
- Other projects use `vsplit`

### Validation Examples

**Invalid Split:**
```lua
require('kiro').setup({ split = "invalid" })
-- Error: split must be one of: 'split', 'vsplit', 'float' (got 'invalid')
--   Suggestion: Try: split = 'vsplit' (vertical), 'split' (horizontal), or 'float'
```

**Invalid Terminal Size:**
```lua
require('kiro').setup({ terminal_size = 5 })
-- Error: terminal_size must be between 10 and 200 (got 5)
--   Suggestion: Try a value between 10 and 200
```

**Invalid Float Options:**
```lua
require('kiro').setup({
  split = "float",
  float_opts = { width = 1.5 }
})
-- Error: float_opts.width must be between 0 and 1
--   Suggestion: Try: float_opts = { width = 0.8 }
```

### Migration Example

```lua
-- Check configuration
local Migrate = require("kiro.migrate")
local config = { split = "vsplit", debug = true }

-- Validate
local valid, issues = Migrate.validate_schema(config)
if not valid then
  for _, issue in ipairs(issues) do
    print(issue.message)
    print("  →", issue.suggestion)
  end
end

-- Check for deprecations (future use)
local warnings = Migrate.check_deprecated(config)
if #warnings > 0 then
  print(Migrate.report(config))
end
```

## Benefits

1. **Better UX**: Clear error messages guide users to fixes
2. **Project Flexibility**: Different configs per project
3. **Future-Proof**: Migration system for config changes
4. **Validation**: Catch errors early with helpful suggestions
5. **Documentation**: Self-documenting with examples

## File Structure

```
project/
├── .kiro.lua              # Project-specific config
├── .kiro/
│   └── settings/
│       └── lsp.json       # LSP configuration
└── init.lua               # Your Neovim config with global Kiro setup
```

## Configuration Priority

1. **Project config** (`.kiro.lua`) - Highest priority
2. **Global config** (`require('kiro').setup()`) - Default
3. **Built-in defaults** - Fallback

## Migration System

The migration system is designed for future config changes:

```lua
-- When we rename an option in the future:
migrations = {
  ["old_name"] = {
    from = "old_name",
    to = "new_name",
    transform = function(value) return value end
  }
}

-- Users get automatic migration:
local migrated, changes = Migrate.migrate(old_config)
-- Changes: [{ from: "old_name", to: "new_name", ... }]
```

## Testing

All 57 tests pass. The validation layer provides:
- Detailed error messages
- Actionable suggestions
- Schema validation
- Project config support

## Example Project Config

See `examples/.kiro.lua` for a complete example with:
- Custom commands
- Project-specific settings
- Commented alternatives
- Best practices

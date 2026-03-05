# Spec: Consolidate Config Validation into Health Check

## Overview

Remove the `:KiroCheckConfig` command and integrate its functionality into `:checkhealth kiro`. This provides a single, standard location for all plugin diagnostics.

## Current State

**Three separate diagnostic commands:**

1. `:KiroCheckConfig` - Validates current configuration
   - Checks for unknown options
   - Validates option types and ranges
   - Shows suggestions for fixes

2. `:KiroLspStatus` - Shows LSP server status
   - Reports active LSP servers
   - Shows LSP configuration
   - LSP-specific diagnostics

3. `:checkhealth kiro` - Basic health check
   - Only checks if kiro-cli is installed
   - Minimal validation

## Proposed Changes

### 1. Enhanced Health Check

Expand `lua/kiro/health.lua` to include:

**Configuration Validation:**
- Validate all config options (types, ranges, enums)
- Report unknown options with suggestions
- Check for deprecated options
- Validate project config (`.kiro.lua`) if present

**LSP Status:**
- Check if LSP is enabled
- Verify `.kiro/settings/lsp.json` exists and is valid
- Report active LSP servers
- Show LSP-related errors

**Terminal Backend:**
- Report which backend is active (default/toggleterm)
- Check toggleterm availability if configured
- Validate terminal-related options

**Command Registry:**
- Report number of registered commands
- List built-in vs custom commands

### 2. Remove Redundant Commands

**Delete:**
- `:KiroCheckConfig` command registration
- `:KiroLspStatus` command registration
- Any standalone config/LSP validation UI

**Keep:**
- Internal validation functions (used during setup)
- Error messages for invalid config during `setup()`
- LSP module functionality (only remove the status command)

### 3. Health Check Output Format

```
kiro: require("kiro.health").check()

kiro-cli ~
- OK kiro-cli found in PATH: /usr/local/bin/kiro-cli

Configuration ~
- OK All configuration options are valid
- OK Using profile: work
- OK Terminal size: 80 columns
- OK Split mode: vsplit

LSP Integration ~
- OK LSP enabled
- OK LSP config found: .kiro/settings/lsp.json
- OK Active servers: lua_ls, rust_analyzer

Terminal Backend ~
- OK Using default terminal backend
- INFO toggleterm.nvim not installed (optional)

Commands ~
- OK 8 commands registered (4 built-in, 4 custom)
- INFO Custom commands: KiroExplain, KiroFix, KiroTest, KiroDoc

Project Configuration ~
- OK Project config found: .kiro.lua
- OK Project config is valid
```

**With Issues:**
```
Configuration ~
- ERROR Unknown option: 'invalid_option'
  Suggestion: Remove from config
- WARNING terminal_size is 5 (minimum: 10)
  Suggestion: Set terminal_size to at least 10

LSP Integration ~
- ERROR Failed to parse .kiro/settings/lsp.json
  Suggestion: Check JSON syntax
```

## Implementation

### File Changes

**lua/kiro/health.lua**
```lua
local M = {}

function M.check()
  -- kiro-cli check (existing)
  check_kiro_cli()
  
  -- NEW: Configuration validation
  check_configuration()
  
  -- NEW: LSP status
  check_lsp()
  
  -- NEW: Terminal backend
  check_terminal_backend()
  
  -- NEW: Command registry
  check_commands()
  
  -- NEW: Project config
  check_project_config()
end
```

**lua/kiro/init.lua**
- Remove `:KiroCheckConfig` registration
- Remove `:KiroLspStatus` registration

**lua/kiro/commands.lua**
- Remove `KiroCheckConfig` from `register_palette_commands()` (if present)

**README.md**
- Remove `:KiroCheckConfig` from commands table
- Remove `:KiroLspStatus` from commands table
- Update health check documentation
- Add examples of enhanced health output

## Benefits

1. **Standard Location** - Users know to run `:checkhealth kiro` for all diagnostics
2. **Comprehensive** - Single command shows everything about plugin state
3. **Neovim Convention** - Follows standard Neovim health check pattern
4. **Less Clutter** - One less command to remember
5. **Better UX** - All diagnostics in one place with consistent formatting

## Migration

**Breaking Changes:**
- `:KiroCheckConfig` will be removed
- `:KiroLspStatus` will be removed

**Migration Path:**
- Users should use `:checkhealth kiro` instead for all diagnostics
- Add deprecation notice in changelog
- No code changes needed for users (just different command)

## Testing

**Update tests:**
- `tests/health_spec.lua` - Add tests for new validation
- Remove any tests for `:KiroCheckConfig`
- Test all validation scenarios (valid, invalid, warnings)

**Test cases:**
- Valid configuration
- Invalid option types
- Unknown options
- Missing kiro-cli
- Invalid LSP config
- Missing project config
- Toggleterm availability

## Acceptance Criteria

- [ ] `:checkhealth kiro` validates all configuration options
- [ ] `:checkhealth kiro` shows LSP status (servers, config, errors)
- [ ] `:checkhealth kiro` shows terminal backend info
- [ ] `:checkhealth kiro` shows command registry info
- [ ] `:checkhealth kiro` validates project config if present
- [ ] `:KiroCheckConfig` command is removed
- [ ] `:KiroLspStatus` command is removed
- [ ] Documentation updated (README, help file)
- [ ] Tests updated and passing
- [ ] Health check output is clear and actionable

## Future Enhancements

- Add performance metrics (startup time, module load times)
- Check for plugin updates
- Validate keymaps for conflicts
- Show history statistics

# Consolidate Health Check Implementation

## Summary

Removed `:KiroCheckConfig` and `:KiroLspStatus` commands and consolidated all diagnostic functionality into `:checkhealth kiro`. This provides a single, standard location for all plugin diagnostics following Neovim conventions.

## Changes

### 1. Enhanced Health Check (`lua/kiro/health.lua`)

Expanded from basic kiro-cli check to comprehensive diagnostics:

**New Sections:**
- **Configuration** - Validates all config options, shows profile, terminal size, split mode
- **LSP Integration** - Checks LSP status, config file, active servers
- **Terminal Backend** - Reports active backend (default/toggleterm), availability
- **Commands** - Shows registered commands (built-in vs custom)
- **Project Configuration** - Validates `.kiro.lua` if present

**Output Format:**
```
kiro-cli ~
- OK kiro-cli found in PATH: /usr/local/bin/kiro-cli

Configuration ~
- OK All configuration options are valid
- INFO Using profile: work
- INFO Terminal size: 80 columns
- INFO Split mode: vsplit

LSP Integration ~
- OK LSP enabled
- OK LSP config found: .kiro/settings/lsp.json
- OK Configured servers: lua_ls, rust_analyzer

Terminal Backend ~
- OK Using default terminal backend

Commands ~
- OK 8 commands registered (4 built-in, 4 custom)
- INFO Custom commands: KiroExplain, KiroFix, KiroTest, KiroDoc

Project Configuration ~
- OK Project config found: .kiro.lua
- OK Project config is valid
```

### 2. Removed Commands (`lua/kiro/init.lua`)

**Deleted:**
- `:KiroCheckConfig` command registration
- `:KiroLspStatus` command registration

**Kept:**
- Internal validation functions (still used during setup)
- LSP module functionality (only removed status command)

### 3. Updated Documentation (`README.md`)

**Removed from commands table:**
- `:KiroCheckConfig`
- `:KiroLspStatus`

**Added:**
- Note directing users to `:checkhealth kiro` for diagnostics
- Comprehensive health check output example
- Detailed explanation of all diagnostic sections

### 4. Updated Tests (`tests/health_spec.lua`)

**Added tests:**
- Configuration validation when plugin is initialized
- LSP config file existence check

**Updated:**
- Removed `KiroLspStatus` from test cleanup in `tests/kiro_spec.lua`

Total tests: 65 → 67 (+2)

## Benefits

1. **Standard Location** - Users know to run `:checkhealth kiro` for all diagnostics
2. **Comprehensive** - Single command shows everything about plugin state
3. **Neovim Convention** - Follows standard Neovim health check pattern
4. **Less Clutter** - Two fewer commands to remember
5. **Better UX** - All diagnostics in one place with consistent formatting
6. **Actionable** - Clear OK/ERROR/WARNING/INFO messages with suggestions

## Migration

**Breaking Changes:**
- `:KiroCheckConfig` removed
- `:KiroLspStatus` removed

**Migration Path:**
Users should use `:checkhealth kiro` instead for all diagnostics. No code changes needed, just a different command.

## Usage

**Before:**
```vim
:KiroCheckConfig      " Check configuration
:KiroLspStatus        " Check LSP status
:checkhealth kiro     " Check kiro-cli only
```

**After:**
```vim
:checkhealth kiro     " All diagnostics in one place
```

## Testing

All 67 tests pass:
- Health check tests verify kiro-cli detection
- Configuration validation tests
- LSP config file checks
- All existing functionality preserved

## Implementation Notes

- Health check uses `vim.health` API (0.10+) with fallback to `require("health")`
- Each diagnostic section is a separate function for clarity
- Gracefully handles missing config, LSP files, or project config
- Shows helpful suggestions for warnings and errors
- Uses standard health check formatting (OK, ERROR, WARN, INFO)

## Status

✅ **Complete**

All diagnostic functionality consolidated into `:checkhealth kiro` with comprehensive output and actionable suggestions.

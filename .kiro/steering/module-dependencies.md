# Module Dependencies Refactoring

## Summary

Reduced module coupling by extracting shared state into a centralized module and documenting dependency relationships. This improves maintainability and prevents circular dependencies.

## Changes

### 1. Centralized State Management (`lua/kiro/state.lua`)

**Before:** State scattered across modules
```lua
-- In init.lua
local state = {
  config = nil,
  initialized = false,
}
```

**After:** Single source of truth
```lua
local State = require("kiro.state")

State.set_config(config)
State.set_initialized(true)
local config = State.get_config()
local is_init = State.is_initialized()
```

**Benefits:**
- Single source of truth for plugin state
- Easier to test (can reset state)
- No state duplication
- Clear state ownership

### 2. Dependency Analyzer (`lua/kiro/deps.lua`)

**Features:**
- Analyze module dependencies
- Detect circular dependencies
- Generate dependency graphs
- Produce dependency reports

**Usage:**
```lua
local Deps = require("kiro.deps")

-- Check for circular dependencies
local has_circular, cycles = Deps.check_circular()

-- Generate DOT graph
local dot = Deps.to_dot()

-- Print report
Deps.report()
```

### 3. Dependency Structure

**Core Modules** (no dependencies):
```
kiro.constants
kiro.error
kiro.state
kiro.validate
```

**Foundation Modules** (minimal dependencies):
```
kiro.logger → kiro.constants
kiro.config → kiro.constants, kiro.error
```

**Feature Modules** (depend on foundation):
```
kiro.commands → kiro.constants, kiro.logger, kiro.error
kiro.history → kiro.logger
kiro.lsp → kiro.logger
```

**Integration Modules** (depend on features):
```
kiro.terminal → kiro.terminal.{shell,window}, kiro.logger, 
                kiro.constants, kiro.history, kiro.error
kiro.init → kiro.config, kiro.logger, kiro.constants, kiro.state
            (lazy: terminal, commands, history, lsp, validate, etc.)
```

## Dependency Graph

```
┌─────────────┐
│ kiro.init   │ (entry point)
└──────┬──────┘
       │
       ├─ kiro.config ──┬─ kiro.constants
       │                └─ kiro.error
       │
       ├─ kiro.logger ─── kiro.constants
       │
       ├─ kiro.state (no deps)
       │
       └─ (lazy loaded)
          ├─ kiro.terminal ──┬─ kiro.terminal.shell
          │                  ├─ kiro.terminal.window
          │                  ├─ kiro.logger
          │                  ├─ kiro.constants
          │                  ├─ kiro.history
          │                  └─ kiro.error
          │
          ├─ kiro.commands ──┬─ kiro.constants
          │                  ├─ kiro.logger
          │                  └─ kiro.error
          │
          ├─ kiro.history ─── kiro.logger
          │
          ├─ kiro.lsp ──────── kiro.logger
          │
          └─ kiro.validate (no deps)
```

## Benefits

### 1. Reduced Coupling
- Modules depend on interfaces, not implementations
- State centralized in one place
- Clear dependency hierarchy

### 2. No Circular Dependencies
- Verified with `Deps.check_circular()`
- Clean dependency tree
- Easy to reason about

### 3. Better Testability
- State can be reset between tests
- Modules can be tested in isolation
- Mock dependencies easily

### 4. Improved Maintainability
- Clear module responsibilities
- Easy to find where state lives
- Documented dependencies

### 5. Lazy Loading Compatible
- Core modules loaded immediately
- Feature modules loaded on demand
- No dependency conflicts

## State Module API

```lua
local State = require("kiro.state")

-- Configuration
State.set_config(config)
local config = State.get_config()

-- Initialization
State.set_initialized(true)
local is_init = State.is_initialized()

-- Debug mode
local is_debug = State.is_debug()

-- Testing
State.reset()  -- Reset all state
```

## Dependency Analysis

### Run Analysis
```lua
:lua require('kiro.deps').report()
```

**Output:**
```
Kiro Module Dependencies
==================================================

✓ No circular dependencies

Module Dependency Count:
  kiro.init                       11 (4 always, 7 lazy)
  kiro.config                      3 (2 always, 1 lazy)
  kiro.terminal                    6 (6 always, 0 lazy)
  kiro.commands                    3 (3 always, 0 lazy)
  kiro.history                     1 (1 always, 0 lazy)
  kiro.lsp                         1 (1 always, 0 lazy)
  kiro.logger                      1 (1 always, 0 lazy)
  kiro.constants                   0 (0 always, 0 lazy)
  kiro.state                       0 (0 always, 0 lazy)
  kiro.error                       0 (0 always, 0 lazy)
  kiro.validate                    0 (0 always, 0 lazy)

Legend:
  always = loaded immediately
  lazy   = loaded on demand
```

### Generate Graph
```lua
:lua print(require('kiro.deps').to_dot())
```

Save to file and visualize:
```bash
lua -e "print(require('kiro.deps').to_dot())" > deps.dot
dot -Tpng deps.dot -o deps.png
```

## Module Responsibilities

### Core Layer
- **constants** - Constants and defaults
- **error** - Error handling
- **state** - Centralized state
- **validate** - Parameter validation

### Foundation Layer
- **logger** - Logging infrastructure
- **config** - Configuration management

### Feature Layer
- **commands** - Command registration
- **history** - Command history
- **lsp** - LSP integration

### Integration Layer
- **terminal** - Terminal management
- **init** - Plugin entry point

## Testing

All 57 tests pass with the refactored state management:

```bash
./scripts/test.sh
# 57/57 tests passing ✓
```

State can be reset between tests:
```lua
local State = require("kiro.state")

before_each(function()
  State.reset()
end)
```

## Migration Notes

**No breaking changes.** The refactoring is internal:
- Public API unchanged
- Same functionality
- Better structure

## Best Practices

### Adding New Modules

1. **Minimize dependencies**
   - Depend only on what you need
   - Prefer core modules over feature modules

2. **Avoid circular dependencies**
   - Check with `Deps.check_circular()`
   - Use lazy loading if needed

3. **Use centralized state**
   - Don't create module-local state for plugin config
   - Use `State` module for shared state

4. **Document dependencies**
   - Update `deps.lua` when adding modules
   - Keep dependency graph current

### Example: Adding a New Module

```lua
--- New feature module
--- @class KiroNewFeature
local M = {}

-- Minimal dependencies
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")
local State = require("kiro.state")

function M.do_something()
  if not State.is_initialized() then
    Logger.error("Not initialized")
    return
  end
  
  local config = State.get_config()
  -- Use config...
end

return M
```

Then update `deps.lua`:
```lua
["kiro.newfeature"] = {
  always = { "kiro.logger", "kiro.constants", "kiro.state" },
  lazy = {},
},
```

## Future Improvements

1. **Dependency Injection** - Pass dependencies explicitly
2. **Event System** - Decouple modules with events
3. **Plugin Architecture** - Allow external modules
4. **Async Loading** - Load modules asynchronously

## Verification

Check for circular dependencies:
```bash
nvim --headless -c "lua require('kiro.deps').report()" -c "quit"
```

Should output:
```
✓ No circular dependencies
```

# Configuration Profiles

## Problem

Users want different configurations for different contexts (work, personal, projects).

## Requirements

1. Define multiple named configuration profiles
2. Switch between profiles easily
3. Profile-specific settings
4. Per-project profile selection

## Acceptance Criteria

- [ ] Define profiles in setup
- [ ] Switch profiles at runtime
- [ ] Profile inherits from base config
- [ ] Project-specific profile in `.kiro.lua`
- [ ] Show current profile in status

## Configuration

```lua
require('kiro').setup({
  profiles = {
    work = {
      profile = 'work',
      split = 'vsplit',
      terminal_size = 100,
    },
    personal = {
      profile = 'personal',
      split = 'float',
      float_opts = { width = 0.9, height = 0.9 },
    },
    minimal = {
      split = 'split',
      terminal_size = 15,
      auto_insert_mode = false,
    },
  },
  active_profile = 'work',  -- Default profile
})
```

## API

```lua
-- Switch profile
kiro.set_profile('personal')

-- Get current profile
local profile = kiro.get_profile()

-- List profiles
local profiles = kiro.list_profiles()
```

## Commands

```vim
:KiroProfile work      " Switch to work profile
:KiroProfile           " Show current profile
:KiroProfiles          " List available profiles
```

## Project-Specific

In `.kiro.lua`:
```lua
return {
  active_profile = 'work',
}
```

## Profile Inheritance

Profiles inherit from base config:
```lua
base_config = { split = 'vsplit', auto_insert_mode = true }
profile_config = { split = 'float' }
-- Result: { split = 'float', auto_insert_mode = true }
```

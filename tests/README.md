# Test Suite

This directory contains tests for kiro.nvim using [plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

## Running Tests

### Prerequisites

Plenary.nvim will be automatically installed to `/tmp/nvim/site/pack/packer/start/plenary.nvim` when running tests.

### Run All Tests

```bash
./scripts/test.sh
```

### Run Specific Test File

```bash
nvim --headless -c "PlenaryBustedFile tests/config_spec.lua"
```

## Test Structure

- `kiro_spec.lua` - Main plugin initialization and setup
- `config_spec.lua` - Configuration validation
- `shell_spec.lua` - Shell command building and escaping
- `window_spec.lua` - Terminal window management

## Writing Tests

Tests use plenary's busted-style API:

```lua
describe("feature", function()
  it("does something", function()
    assert.equals(expected, actual)
  end)
end)
```

See [plenary.nvim documentation](https://github.com/nvim-lua/plenary.nvim#plenarytest_harness) for more details.

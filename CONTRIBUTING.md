# Contributing to kiro.nvim

Thanks for your interest in contributing to kiro.nvim!

## Development Setup

1. Clone the repository:
```bash
git clone https://github.com/seagoj/kiro.nvim.git
cd kiro.nvim
```

2. Install dependencies:
- [kiro-cli](https://kiro.ai) - Required for testing
- [stylua](https://github.com/JohnnyMorganz/StyLua) - Code formatting
- [luacheck](https://github.com/mpeterv/luacheck) - Linting

3. Test locally by adding to your Neovim config:
```lua
{
  dir = '~/path/to/kiro.nvim',
  opts = {}
}
```

## Code Style

Run before committing:

```bash
# Format code
stylua .

# Lint code
luacheck .
```

Configuration:
- `stylua.toml` - Formatting rules (tabs, 120 chars)
- `.luacheckrc` - Linting rules

## Making Changes

1. Create a feature branch from `main`
2. Make your changes
3. Format and lint your code
4. Test manually in Neovim
5. Update README.md if adding features
6. Submit a pull request

## Pull Request Guidelines

- Keep changes focused and atomic
- Include clear commit messages
- Update documentation for new features
- Ensure code passes stylua and luacheck
- Test with both `split` and `vsplit` configurations
- Test with `reuse_terminal` enabled and disabled

## Project Structure

```
lua/kiro/
├── init.lua           # Main entry point
├── config.lua         # Configuration management
├── commands.lua       # Command registration
├── health.lua         # Health checks
└── terminal/
    ├── init.lua       # Terminal management
    ├── window.lua     # Window/buffer handling
    └── shell.lua      # Shell utilities
```

## Adding Features

### New Configuration Options

1. Add default to `config.lua` `M.defaults`
2. Add validation in `validate()` function
3. Document in README.md
4. Use in relevant module

### New Commands

Commands are registered via `commands.register()`. See README.md examples section.

## Questions?

Open an issue for discussion before starting major changes.

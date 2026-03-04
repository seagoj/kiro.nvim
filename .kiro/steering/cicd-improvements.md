# CI/CD Improvements

## Summary

Enhanced CI/CD pipeline with multi-version testing, code coverage reporting, and automated releases.

## Changes Made

### 1. Multi-Version Testing

**Test against multiple Neovim versions:**
- v0.9.5 (minimum supported)
- v0.10.0 (latest stable)
- stable (current stable)
- nightly (bleeding edge)

**Benefits:**
- Catch version-specific issues early
- Ensure compatibility across versions
- Test against latest features
- Verify minimum version support

**Matrix strategy:**
```yaml
strategy:
  matrix:
    neovim-version: ['v0.9.5', 'v0.10.0', 'stable', 'nightly']
```

### 2. Code Coverage Reporting

**Automated coverage with luacov:**
- Runs on stable Neovim version
- Generates lcov format reports
- Uploads to Codecov
- Shows coverage badge in README

**Coverage script** (`scripts/test-coverage.sh`):
- Installs luacov and reporter
- Configures coverage for lua/kiro only
- Excludes test files
- Generates lcov.info for Codecov

**Run locally:**
```bash
./scripts/test-coverage.sh
```

**Coverage configuration:**
```lua
{
  include = { "lua/kiro" },
  exclude = { "tests/" }
}
```

### 3. Automated Releases

**Release workflow** (`.github/workflows/release.yml`):
- Triggers on version tags (v*)
- Generates changelog from commits
- Creates GitHub release
- Includes installation instructions

**Creating a release:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Release includes:**
- Changelog (commits since last tag)
- Installation instructions for lazy.nvim
- Installation instructions for packer.nvim
- Automatic GitHub release creation

### 4. CI Badges

**README badges show:**
- Test status (passing/failing)
- Code coverage percentage
- License information

## Workflow Structure

### Test Workflow (`.github/workflows/test.yml`)

**Jobs:**
1. **test** - Run tests on all Neovim versions
   - Matrix: 4 versions
   - Coverage on stable only
   - Upload to Codecov

2. **lint** - Code quality checks
   - stylua (formatting)
   - luacheck (linting)

3. **health** - Health check verification
   - Runs `:checkhealth kiro`
   - Verifies plugin loads

### Release Workflow (`.github/workflows/release.yml`)

**Triggers:** Push to tags matching `v*`

**Steps:**
1. Checkout with full history
2. Generate changelog from commits
3. Create GitHub release with:
   - Changelog
   - Installation instructions
   - Version tag

## Testing Locally

### Run tests
```bash
./scripts/test.sh
```

### Run with coverage
```bash
./scripts/test-coverage.sh
```

### Check coverage report
```bash
cat coverage/luacov.report.out
```

### View lcov info
```bash
cat coverage/lcov.info
```

## CI/CD Pipeline Flow

### On Pull Request
1. Run tests on all Neovim versions
2. Run linting (stylua, luacheck)
3. Run health check
4. Generate coverage (stable only)
5. Upload coverage to Codecov

### On Push to Main
Same as pull request

### On Tag Push (v*)
1. Run all tests
2. Generate changelog
3. Create GitHub release
4. Publish release notes

## Coverage Metrics

**Current coverage areas:**
- Configuration validation
- Command registration
- Terminal management
- Window operations
- Shell utilities
- Error handling
- Health checks

**Excluded from coverage:**
- Test files
- Example configurations

## Release Process

### Manual Release Steps

1. **Update version** (if needed in docs)
2. **Commit changes**
   ```bash
   git commit -am "Release v1.0.0"
   ```

3. **Create tag**
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   ```

4. **Push tag**
   ```bash
   git push origin v1.0.0
   ```

5. **GitHub Actions automatically:**
   - Runs all tests
   - Generates changelog
   - Creates release
   - Publishes release notes

### Semantic Versioning

Follow semver (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

## Benefits

### For Users
- Confidence in stability across Neovim versions
- Clear release notes with changelogs
- Easy installation with version pinning
- Visible test and coverage status

### For Developers
- Automated testing on multiple versions
- Coverage tracking over time
- Automated release process
- Clear CI/CD feedback

### For Maintainers
- Catch regressions early
- Track code coverage trends
- Streamlined release process
- Professional project presentation

## Monitoring

### CI Status
Check: https://github.com/seagoj/kiro.nvim/actions

### Coverage Reports
Check: https://codecov.io/gh/seagoj/kiro.nvim

### Releases
Check: https://github.com/seagoj/kiro.nvim/releases

## Future Enhancements

Potential additions:
- Performance benchmarks
- Integration tests with real kiro-cli
- Automated dependency updates
- Release notes generation from conventional commits
- Automated version bumping

#!/usr/bin/env bash

set -e

# Create coverage directory
mkdir -p coverage

# Create luacov config
cat > .luacov << EOF
return {
  statsfile = "coverage/luacov.stats.out",
  reportfile = "coverage/luacov.report.out",
  include = {
    "lua/kiro"
  },
  exclude = {
    "tests/"
  }
}
EOF

# Run tests with coverage
nvim --headless --noplugin -u scripts/minimal_init.lua \
  -c "lua require('plenary.test_harness').test_directory('tests', { minimal_init = 'scripts/minimal_init.lua' })" 2>&1

# Generate coverage report
luacov
luacov-reporter-lcov -o coverage/lcov.info

# Display summary
echo ""
echo "Coverage report generated at coverage/lcov.info"
echo ""
grep -A 3 "^Summary" coverage/luacov.report.out || true

# Clean up
rm -f .luacov

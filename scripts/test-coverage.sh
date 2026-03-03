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

# Check if stats file was created
if [ ! -f coverage/luacov.stats.out ]; then
  echo "ERROR: luacov.stats.out was not created"
  echo "Checking if luacov is loaded..."
  nvim --headless -u scripts/minimal_init.lua \
    -c "lua local ok = pcall(require, 'luacov.runner'); print('luacov available:', ok)" \
    -c "quit" 2>&1
  exit 1
fi

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

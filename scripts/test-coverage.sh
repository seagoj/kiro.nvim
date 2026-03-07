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
  --cmd "let g:loaded_netrw = 1 | let g:loaded_netrwPlugin = 1" \
  -c "lua require('plenary.test_harness').test_directory('tests', { minimal_init = 'scripts/minimal_init.lua' })" 2>&1 | tee coverage_output.log

# Check if tests failed
if grep -q "Failed : [1-9]" coverage_output.log; then
  echo "Tests failed!"
  rm -f coverage_output.log
  exit 1
fi
rm -f coverage_output.log

# Check if stats file was created
if [ ! -f coverage/luacov.stats.out ]; then
  echo "WARNING: luacov.stats.out was not created - coverage not available"
  echo "Tests passed but coverage could not be generated"
  exit 0
fi

# Generate coverage report
luacov

# Convert to lcov format using lua directly
lua5.1 -e "package.path='/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;'..package.path; require('luacov.reporter.lcov').report()" > coverage/lcov.info

# Display summary
echo ""
echo "Coverage report generated at coverage/lcov.info"
echo ""
grep -A 3 "^Summary" coverage/luacov.report.out || true

# Clean up
rm -f .luacov

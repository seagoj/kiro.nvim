#!/usr/bin/env bash
# Benchmark startup time for kiro.nvim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Benchmarking kiro.nvim startup time..."
echo "========================================"
echo ""

# Create minimal init file for benchmarking
BENCH_INIT=$(mktemp)
cat > "$BENCH_INIT" << 'EOF'
-- Minimal init for benchmarking
vim.opt.runtimepath:append('.')

local start = vim.loop.hrtime()
require('kiro').setup({
  register_default_commands = true,
  split = 'vsplit',
  enable_lsp = false,  -- Disable LSP for pure plugin benchmark
})
local elapsed = (vim.loop.hrtime() - start) / 1e6  -- Convert to milliseconds

print(string.format("Setup time: %.2f ms", elapsed))
vim.cmd('quit')
EOF

# Run benchmark multiple times
ITERATIONS=10
TOTAL=0

echo "Running $ITERATIONS iterations..."
for i in $(seq 1 $ITERATIONS); do
  TIME=$(nvim --headless -u "$BENCH_INIT" 2>&1 | grep "Setup time" | awk '{print $3}')
  echo "  Iteration $i: $TIME ms"
  TOTAL=$(echo "$TOTAL + $TIME" | bc)
done

AVG=$(echo "scale=2; $TOTAL / $ITERATIONS" | bc)

echo ""
echo "========================================"
echo "Average setup time: $AVG ms"
echo "========================================"

# Cleanup
rm "$BENCH_INIT"

# Module loading analysis
echo ""
echo "Module Loading Analysis:"
echo "------------------------"

cat > "$BENCH_INIT" << 'EOF'
vim.opt.runtimepath:append('.')

-- Track module loads
local loaded_modules = {}
local original_require = require
_G.require = function(name)
  if name:match('^kiro') and not loaded_modules[name] then
    loaded_modules[name] = true
  end
  return original_require(name)
end

-- Setup
require('kiro').setup({
  register_default_commands = true,
  enable_lsp = false,
})

-- Print loaded modules
print("\nModules loaded during setup:")
for name, _ in pairs(loaded_modules) do
  print("  - " .. name)
end

vim.cmd('quit')
EOF

nvim --headless -u "$BENCH_INIT" 2>&1 | grep -A 100 "Modules loaded"

rm "$BENCH_INIT"

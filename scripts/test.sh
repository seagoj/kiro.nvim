#!/usr/bin/env bash
# Run tests using plenary.nvim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Cleanup function
cleanup() {
	# Kill all nvim processes running our tests (graceful first)
	pkill -f "minimal_init.lua.*plenary" 2>/dev/null || true
	sleep 0.5
	# Force kill any remaining
	pkill -9 -f "minimal_init.lua.*plenary" 2>/dev/null || true
	pkill -9 -f "plenary.busted" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

# Run tests
echo "Running tests..."
nvim --headless \
	--cmd "let g:loaded_netrw = 1 | let g:loaded_netrwPlugin = 1" \
	-u "$SCRIPT_DIR/minimal_init.lua" \
	-c "PlenaryBustedDirectory $PROJECT_ROOT/tests/ { minimal_init = '$SCRIPT_DIR/minimal_init.lua' }"

echo "Tests completed successfully!"

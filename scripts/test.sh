#!/usr/bin/env bash
# Run tests using plenary.nvim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Run tests (plenary will be auto-installed by minimal_init.lua)
echo "Running tests..."
nvim --headless \
	-u "$SCRIPT_DIR/minimal_init.lua" \
	-c "PlenaryBustedDirectory $PROJECT_ROOT/tests/ { minimal_init = '$SCRIPT_DIR/minimal_init.lua' }"

echo "Tests completed successfully!"

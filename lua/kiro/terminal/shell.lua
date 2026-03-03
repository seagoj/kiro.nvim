--- Shell utilities for safe command execution
--- @class KiroShell
local M = {}

--- Escape single quotes for safe shell argument passing
--- @param arg string Argument to escape
--- @return string Escaped argument
function M.escape_arg(arg)
	return arg:gsub("'", "'\\''")
end

--- Build kiro-cli command with escaped message
--- @param message string Message to send to kiro-cli
--- @return string Shell command
function M.build_command(message)
	return string.format("kiro-cli chat '%s'", M.escape_arg(message))
end

return M

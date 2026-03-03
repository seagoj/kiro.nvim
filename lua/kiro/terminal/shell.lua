--- Shell utilities for safe command execution
--- @class KiroShell
local M = {}

local Constants = require("kiro.constants")

--- Escape single quotes for safe shell argument passing
--- @param arg string Argument to escape
--- @return string Escaped argument
function M.escape_arg(arg)
	return arg:gsub("'", "'\\''")
end

--- Build kiro-cli command with escaped message
--- @param message string Message to send to kiro-cli
--- @param profile string|nil Optional profile name
--- @return string Shell command
function M.build_command(message, profile)
	local cmd = Constants.CLI.EXECUTABLE .. " " .. Constants.CLI.COMMAND
	if profile then
		cmd = cmd .. " " .. Constants.CLI.PROFILE_FLAG .. " " .. profile
	end
	return string.format("%s '%s'", cmd, M.escape_arg(message))
end

return M

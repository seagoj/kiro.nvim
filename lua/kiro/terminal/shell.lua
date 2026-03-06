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

--- Parse session list output from kiro-cli
--- @param output string Raw output from --list-sessions
--- @return table Array of session objects {id, time_ago, preview, msg_count}
function M.parse_sessions(output)
	local sessions = {}
	local current_id = nil

	for line in output:gmatch("[^\n]+") do
		-- Strip ANSI codes
		line = line:gsub("\27%[[0-9;]*m", "")

		-- Check for session ID line
		local id = line:match("Chat SessionId:%s*(.+)")
		if id then
			current_id = id:gsub("^%s+", ""):gsub("%s+$", "")
		elseif current_id and line:match("|") then
			-- This is the details line
			local time_ago, preview, msg_count = line:match("^%s*([^|]+)|([^|]+)|[^|]*(%d+)%s+msgs")
			if time_ago and preview and msg_count then
				table.insert(sessions, {
					id = current_id,
					time_ago = time_ago:gsub("^%s+", ""):gsub("%s+$", ""),
					preview = preview:gsub("^%s+", ""):gsub("%s+$", ""),
					msg_count = tonumber(msg_count) or 0,
				})
				current_id = nil
			end
		end
	end

	return sessions
end

--- Build kiro-cli command with escaped message
--- @param message string Message to send to kiro-cli
--- @param profile string|nil Optional profile name
--- @param opts table|nil Optional flags (resume, resume_picker, session_id)
--- @return string Shell command
function M.build_command(message, profile, opts)
	opts = opts or {}
	local cmd = Constants.CLI.EXECUTABLE .. " " .. Constants.CLI.COMMAND

	if opts.resume then
		cmd = cmd .. " --resume"
	elseif opts.resume_picker then
		cmd = cmd .. " --resume-picker"
	end

	if profile then
		cmd = cmd .. " " .. Constants.CLI.PROFILE_FLAG .. " " .. profile
	end

	if message ~= "" then
		return string.format("%s '%s'", cmd, M.escape_arg(message))
	end

	return cmd
end

return M

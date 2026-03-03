--- Terminal management for Kiro chat sessions
--- @class KiroTerminal
local M = {}

local Shell = require("kiro.terminal.shell")
local Window = require("kiro.terminal.window")

--- Open new terminal with kiro-cli
--- @param message string Message to send to kiro-cli
--- @param config table Configuration options
--- @return nil
function M.open(message, config)
	if vim.fn.executable("kiro-cli") == 0 then
		vim.notify("kiro-cli not found in PATH", vim.log.levels.ERROR)
		return
	end

	local split_cmd = config.split

	-- Try to reuse existing terminal
	if config.reuse_terminal and Window.focus_or_create(split_cmd) then
		if Window.send_message(message) then
			if config.auto_insert_mode then
				vim.cmd("startinsert")
			end
			return
		end
	end

	-- Create new terminal
	local command = Shell.build_command(message)
	Window.create(command, split_cmd)

	if config.auto_insert_mode then
		vim.cmd("startinsert")
	end
end

--- Close and cleanup terminal
function M.close()
	Window.close()
end

return M

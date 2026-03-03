--- Terminal management for Kiro chat sessions
--- @class KiroTerminal
local M = {}

local Shell = require("kiro.terminal.shell")
local Window = require("kiro.terminal.window")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")

--- Open new terminal with kiro-cli
--- @param message string Message to send to kiro-cli
--- @param config KiroConfigOptions Configuration options
--- @return boolean success True if terminal opened successfully
--- @return string|nil error Error message if failed
function M.open(message, config)
	if vim.fn.executable(Constants.CLI.EXECUTABLE) == 0 then
		return false, Constants.MESSAGES.KIRO_CLI_NOT_FOUND
	end

	local split_cmd = config.split

	-- Show loading indicator
	Logger.info(Constants.MESSAGES.LOADING)

	-- Try to reuse existing terminal
	if config.reuse_terminal and Window.focus_or_create(split_cmd) then
		local success, err = Window.send_message(message)
		if success then
			if config.auto_insert_mode then
				vim.cmd("startinsert")
			end
			Logger.info(Constants.MESSAGES.SENT)
			return true, nil
		end
		-- If send failed, fall through to create new terminal
		Logger.warn(Constants.MESSAGES.TERMINAL_REUSE_FAILED)
	end

	-- Create new terminal
	local command = Shell.build_command(message, config.profile)
	Logger.debug("Creating terminal with command: %s", command)
	local success, err = Window.create(command, split_cmd, config)
	if not success then
		return false, err
	end

	Window.send_message(message) -- Store the initial message
	if config.auto_insert_mode then
		vim.cmd("startinsert")
	end
	return true, nil
end

--- Close and cleanup terminal
function M.close()
	Window.close()
end

return M

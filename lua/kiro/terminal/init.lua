--- Terminal management for Kiro chat sessions
--- @class KiroTerminal
local M = {}

local Shell = require("kiro.terminal.shell")
local Window = require("kiro.terminal.window")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")
local History = require("kiro.history")

--- Get appropriate terminal backend
--- @param config KiroConfigOptions Configuration options
--- @return table backend Terminal backend module
local function get_backend(config)
	if config.use_toggleterm then
		local Toggleterm = require("kiro.terminal.toggleterm")
		if Toggleterm.is_available() then
			Logger.debug("Using toggleterm backend")
			return Toggleterm
		end
		Logger.warn("toggleterm not available, falling back to default terminal")
	end
	return Window
end

--- Open new terminal with kiro-cli
--- @param message string Message to send to kiro-cli
--- @param config KiroConfigOptions Configuration options
--- @return boolean success True if terminal opened successfully
--- @return string|nil error Error message if failed
function M.open(message, config)
	if vim.fn.executable(Constants.CLI.EXECUTABLE) == 0 then
		return false, Constants.MESSAGES.KIRO_CLI_NOT_FOUND
	end

	local backend = get_backend(config)
	local split_cmd = config.split

	-- Show loading indicator
	Logger.info(Constants.MESSAGES.LOADING)

	-- Try to reuse existing terminal (only for default backend)
	if config.reuse_terminal and backend == Window and Window.focus_or_create(split_cmd) then
		local success = Window.send_message(message)
		if success then
			History.add(message)
			if config.auto_insert_mode then
				vim.cmd("startinsert")
			end
			Logger.info(Constants.MESSAGES.SENT)
			return true, nil
		end
		-- If send failed, fall through to create new terminal
		Logger.warn(Constants.MESSAGES.TERMINAL_REUSE_FAILED)
	end

	-- Create new terminal or use toggleterm
	if backend ~= Window then
		local success, err = backend.open(message, config)
		if success then
			History.add(message)
		end
		return success, err
	end

	-- Default backend
	local command = Shell.build_command(message, config.profile)
	Logger.debug("Creating terminal with command: %s", command)
	local success, err = Window.create(command, split_cmd, config)
	if not success then
		return false, err
	end

	Window.send_message(message) -- Store the initial message
	History.add(message)
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

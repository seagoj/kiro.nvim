--- Terminal management for Kiro chat sessions
--- @class KiroTerminal
local M = {}

local Shell = require("kiro.terminal.shell")
local Window = require("kiro.terminal.window")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")
local Error = require("kiro.error")

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
--- @return ErrorResult
function M.open(message, config)
	if vim.fn.executable(Constants.CLI.EXECUTABLE) == 0 then
		Logger.error(Constants.MESSAGES.KIRO_CLI_NOT_FOUND, { notify = true, title = "Kiro" })
		return Error.err(Constants.MESSAGES.KIRO_CLI_NOT_FOUND, Error.codes.CLI_NOT_FOUND)
	end

	local backend = get_backend(config)
	local split_cmd = config.split

	Logger.info(Constants.MESSAGES.LOADING)

	-- Try to reuse existing terminal (only for default backend)
	if backend == Window and Window.focus_or_create(split_cmd, config) then
		local result = Window.send_message(message)
		if Error.is_ok(result) then
			if config.auto_insert_mode then
				vim.cmd("startinsert")
			end
			Logger.info(Constants.MESSAGES.SENT)
			return Error.ok()
		end
		Logger.warn(Constants.MESSAGES.TERMINAL_REUSE_FAILED)
	end

	-- Create new terminal or use toggleterm
	if backend ~= Window then
		local result = backend.open(message, config)
		if Error.is_err(result) then
			Logger.error(result.error or "Failed to open terminal", { notify = true, title = "Kiro" })
		end
		return result
	end

	-- Default backend
	local command = Shell.build_command(message, config.profile)
	Logger.debug("Creating terminal with command: %s", command)
	local result = Window.create(command, split_cmd, config)
	if Error.is_err(result) then
		Logger.error(result.error or "Failed to create terminal", { notify = true, title = "Kiro" })
		return result
	end

	Window.send_message(message)
	if config.auto_insert_mode then
		vim.cmd("startinsert")
	end
	return Error.ok()
end

--- Close and cleanup terminal
function M.close()
	Window.close()
end

--- Open terminal with custom command (for resume/resume-picker)
--- @param command string Full kiro-cli command
--- @param config KiroConfigOptions Configuration options
--- @return ErrorResult
function M.open_with_command(command, config)
	if vim.fn.executable(Constants.CLI.EXECUTABLE) == 0 then
		Logger.error(Constants.MESSAGES.KIRO_CLI_NOT_FOUND, { notify = true, title = "Kiro" })
		return Error.err(Constants.MESSAGES.KIRO_CLI_NOT_FOUND, Error.codes.CLI_NOT_FOUND)
	end

	local backend = get_backend(config)
	local split_cmd = config.split

	Logger.info(Constants.MESSAGES.LOADING)

	-- Create new terminal
	if backend ~= Window then
		-- For toggleterm, we need to adapt the command
		local result = backend.open("", config)
		if Error.is_err(result) then
			Logger.error(result.error or "Failed to open terminal", { notify = true, title = "Kiro" })
		end
		return result
	end

	-- Default backend
	Logger.debug("Creating terminal with command: %s", command)
	local result = Window.create(command, split_cmd, config)
	if Error.is_err(result) then
		Logger.error(result.error or "Failed to create terminal", { notify = true, title = "Kiro" })
		return result
	end

	if config.auto_insert_mode then
		vim.cmd("startinsert")
	end
	return Error.ok()
end

return M

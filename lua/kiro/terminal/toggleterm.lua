--- Toggleterm integration for Kiro terminal
--- @class KiroToggleterm
local M = {}

local Shell = require("kiro.terminal.shell")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")
local Error = require("kiro.error")

--- @type Terminal|nil
local term = nil

--- Check if toggleterm is available
--- @return boolean available True if toggleterm is installed
function M.is_available()
	local ok, _ = pcall(require, "toggleterm.terminal")
	return ok
end

--- Create or get toggleterm instance
--- @param config KiroConfigOptions Configuration options
--- @return Terminal terminal Toggleterm instance
local function get_terminal(config)
	if term then
		return term
	end

	local Terminal = require("toggleterm.terminal").Terminal

	-- Determine direction based on split config
	local direction
	if config.split == "float" then
		direction = "float"
	elseif config.split == "split" then
		direction = "horizontal"
	else
		direction = "vertical"
	end

	local size = config.terminal_size or (direction == "horizontal" and 15 or 80)

	term = Terminal:new({
		direction = direction,
		size = size,
		close_on_exit = false,
		float_opts = config.split == "float" and config.float_opts or nil,
		on_open = function()
			if config.keymaps and config.keymaps.close then
				vim.keymap.set("n", config.keymaps.close, function()
					M.close()
				end, { buffer = term.bufnr, silent = true, desc = "Close Kiro terminal" })
			end
			if config.keymaps and config.keymaps.resend then
				vim.keymap.set("n", config.keymaps.resend, function()
					M.resend()
				end, { buffer = term.bufnr, silent = true, desc = "Resend last message" })
			end
		end,
	})

	return term
end

--- @type string|nil
local last_message = nil

--- Open terminal with message
--- @param message string Message to send
--- @param config KiroConfigOptions Configuration options
--- @return ErrorResult
function M.open(message, config)
	if vim.fn.executable(Constants.CLI.EXECUTABLE) == 0 then
		return Error.err(Constants.MESSAGES.KIRO_CLI_NOT_FOUND, Error.codes.CLI_NOT_FOUND)
	end

	local result = Error.wrap(function()
		local terminal = get_terminal(config)
		local command = Shell.build_command(message, config.profile)

		terminal.cmd = command
		terminal:open()

		last_message = message

		if config.auto_insert_mode then
			vim.cmd("startinsert")
		end

		Logger.debug("Toggleterm opened with command: %s", command)
	end, "Failed to open toggleterm", Error.codes.CREATE_FAILED)

	return result
end

--- Close terminal
function M.close()
	if term then
		term:close()
	end
end

--- Resend last message
--- @return boolean success True if message was resent
function M.resend()
	if not last_message then
		Logger.warn(Constants.MESSAGES.NO_PREVIOUS_MESSAGE)
		return false
	end

	if term and term:is_open() then
		term:send(Shell.escape_arg(last_message) .. "\n")
		Logger.debug("Message resent via toggleterm")
		return true
	end

	return false
end

--- Get last message
--- @return string|nil Last message
function M.get_last_message()
	return last_message
end

return M

--- Neovim plugin for Kiro AI chat integration
--- @class Kiro
local M = {}

local Config = require("kiro.config")
local Terminal = require("kiro.terminal")
local Commands = require("kiro.commands")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")
local Lsp = require("kiro.lsp")

local state = {
	config = nil,
	initialized = false,
}

--- Setup the Kiro plugin with optional configuration
--- @param opts KiroConfigOptions|nil Configuration options
function M.setup(opts)
	local config, err = Config.init(opts)
	if err ~= nil then
		Logger.error("Invalid config: %s", { notify = true }, err)
		return
	end
	if not config.force_setup and state.initialized then
		return
	end

	-- Enable logging if debug mode is on
	if config.debug then
		Logger.enable(Constants.LOG_LEVELS.DEBUG)
		Logger.debug("Configuration: %s", vim.inspect(config))
	end

	-- Set history size
	local History = require("kiro.history")
	History.set_max_size(config.history_size)

	state.config = config
	state.initialized = true

	if config.register_default_commands then
		for name, prompt in pairs(config.default_commands) do
			M.register_command(name, prompt)
		end
	end

	for name, prompt in pairs(config.commands) do
		M.register_command(name, prompt)
	end

	-- Setup LSP integration if enabled
	if config.enable_lsp then
		local lsp_ok = Lsp.setup()

		-- Register LSP status command only if LSP setup succeeded
		if lsp_ok then
			vim.api.nvim_create_user_command("KiroLspStatus", function()
				Lsp.show_status()
			end, { desc = "Show Kiro LSP server status" })
		end
	end

	-- Register session management commands
	vim.api.nvim_create_user_command("KiroSession", function(opts)
		if opts.args == "" then
			-- Show current session
			local current = M.get_session()
			vim.notify("Current session: " .. current, vim.log.levels.INFO, { title = "Kiro" })
		else
			-- Switch session
			M.set_session(opts.args)
			vim.notify("Switched to session: " .. opts.args, vim.log.levels.INFO, { title = "Kiro" })
		end
	end, {
		nargs = "?",
		desc = "Get or set current Kiro terminal session",
		complete = function()
			local sessions = M.list_sessions()
			local names = {}
			for name, _ in pairs(sessions) do
				table.insert(names, name)
			end
			return names
		end,
	})

	vim.api.nvim_create_user_command("KiroSessions", function()
		local sessions = M.list_sessions()
		local current = M.get_session()
		local lines = { "Kiro Terminal Sessions", string.rep("=", 40), "" }

		if vim.tbl_count(sessions) == 0 then
			table.insert(lines, "No sessions")
		else
			for name, info in pairs(sessions) do
				local marker = name == current and "* " or "  "
				local status = info.active and "Active" or "Inactive"
				table.insert(lines, string.format("%s%s - %s", marker, name, status))
				if info.last_message then
					table.insert(lines, string.format("    Last: %s", info.last_message:sub(1, 50)))
				end
			end
		end

		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Kiro Sessions" })
	end, { desc = "List all Kiro terminal sessions" })

	Logger.debug("Kiro initialized successfully")
end

--- Register a custom command
--- @param name string Command name
--- @param prompt string|function Prompt text or function that returns prompt
function M.register_command(name, prompt)
	if not state.initialized then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED)
		return
	end
	Logger.debug("Registering command: %s", name)
	Commands.register(name, prompt, Terminal, state.config)
end

--- Close the Kiro terminal
function M.close_terminal()
	Logger.debug("Closing terminal")
	Terminal.close()
end

--- Clear the Kiro terminal (close and clear history)
function M.clear_terminal()
	Logger.debug("Clearing terminal")
	Terminal.close()
	local History = require("kiro.history")
	History.clear()
	Logger.info("Terminal cleared")
end

--- Resend the last message to Kiro
function M.resend()
	if not state.initialized then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED, { notify = true })
		return
	end

	local Window = require("kiro.terminal.window")
	local last = Window.get_last_message()
	if last then
		Logger.debug("Resending last message")
		local success, err = Terminal.open(last, state.config)
		if not success then
			Logger.error(Constants.MESSAGES.FAILED_TO_RESEND, { notify = true }, err or "unknown error")
		end
	else
		Logger.warn(Constants.MESSAGES.NO_PREVIOUS_MESSAGE, { notify = true })
	end
end

--- Get command history
--- @return string[] List of previous messages
function M.get_history()
	local History = require("kiro.history")
	return History.get_all()
end

--- Clear command history
function M.clear_history()
	local History = require("kiro.history")
	History.clear()
	Logger.info("Command history cleared")
end

--- Send a message from history
--- @param index number History index (1 = oldest, -1 = newest)
function M.send_from_history(index)
	if not state.initialized then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED, { notify = true })
		return
	end

	local History = require("kiro.history")
	local history = History.get_all()

	if #history == 0 then
		Logger.warn("No command history", { notify = true })
		return
	end

	-- Handle negative indices
	if index < 0 then
		index = #history + index + 1
	end

	if index < 1 or index > #history then
		Logger.error("Invalid history index: %d (history size: %d)", { notify = true }, index, #history)
		return
	end

	local message = history[index]
	Logger.debug("Sending from history [%d]: %s", index, message)
	local success, err = Terminal.open(message, state.config)
	if not success then
		Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, err or "unknown error")
	end
end

--- Send message with multiple files as context
--- @param prompt string Prompt text
--- @param files string[] List of file paths
function M.send_with_files(prompt, files)
	if not state.initialized then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED, { notify = true })
		return
	end

	Logger.debug("Sending with %d files", #files)
	local success, err = Commands.send_with_files(prompt, files, Terminal, state.config)
	if not success then
		Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, err or "unknown error")
	end
end

--- Get LSP server status
--- @return table Status of all configured LSP servers
function M.lsp_status()
	return Lsp.get_status()
end

--- Show LSP status in floating window
function M.lsp_show_status()
	Lsp.show_status()
end

--- Detect available LSP servers
--- @return table Detected LSP servers
function M.lsp_detect()
	return Lsp.detect_servers()
end

--- Set current terminal session
--- @param name string Session name
function M.set_session(name)
	local Window = require("kiro.terminal.window")
	Window.set_session(name)
end

--- Get current terminal session name
--- @return string
function M.get_session()
	local Window = require("kiro.terminal.window")
	return Window.get_current_session()
end

--- List all terminal sessions
--- @return table<string, {active: boolean, last_message: string|nil}>
function M.list_sessions()
	local Window = require("kiro.terminal.window")
	return Window.list_sessions()
end

--- Close all terminal sessions
function M.close_all_sessions()
	local Window = require("kiro.terminal.window")
	Window.close_all()
end

return M

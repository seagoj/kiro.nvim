--- Neovim plugin for Kiro AI chat integration
--- @class Kiro
local M = {}

-- Lazy-loaded modules (loaded on first use)
local _modules = {}

--- Lazy load a module
--- @param name string Module name
--- @return any module Loaded module
local function lazy_require(name)
	if not _modules[name] then
		_modules[name] = require(name)
	end
	return _modules[name]
end

-- Always-loaded modules (needed for setup)
local Config = require("kiro.config")
local Commands = require("kiro.commands")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")
local State = require("kiro.state")

--- Setup the Kiro plugin with optional configuration
--- @param opts KiroConfigOptions|nil Configuration options
function M.setup(opts)
	-- Try to load project-specific config
	local merged_opts, project_err = Config.merge_with_project(opts)
	if project_err then
		Logger.warn("Project config error: %s", project_err)
	end

	local result = Config.init(merged_opts)
	if not result.ok then
		Logger.error("Invalid config: %s", { notify = true }, result.error)
		return
	end
	local config = result.value

	if not config.force_setup and State.is_initialized() then
		return
	end

	if config.debug then
		Logger.enable(Constants.LOG_LEVELS.DEBUG)
		Logger.debug("Configuration: %s", vim.inspect(config))
	end

	local History = lazy_require("kiro.history")
	History.set_max_size(config.history_size)

	State.set_config(config)
	State.set_initialized(true)

	if config.register_default_commands then
		for name, prompt in pairs(config.default_commands) do
			M.register_command(name, prompt)
		end
	end

	for name, prompt in pairs(config.commands) do
		M.register_command(name, prompt)
	end

	-- Setup LSP integration if enabled (lazy load only if config exists)
	-- Setup LSP integration if enabled (lazy load only if config exists)
	if config.enable_lsp then
		local lsp_config_path = vim.fn.getcwd() .. "/.kiro/settings/lsp.json"
		if vim.fn.filereadable(lsp_config_path) == 1 then
			local Lsp = lazy_require("kiro.lsp")
			local lsp_ok = Lsp.setup()

			if lsp_ok then
				vim.api.nvim_create_user_command("KiroLspStatus", function()
					lazy_require("kiro.lsp").show_status()
				end, { desc = "Show Kiro LSP server status" })
			end
		end
	end

	-- Register session management commands
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
				local marker = name == current and "* " or "	"
				local status = info.active and "Active" or "Inactive"
				table.insert(lines, string.format("%s%s - %s", marker, name, status))
				if info.last_message then
					table.insert(lines, string.format("		 Last: %s", info.last_message:sub(1, 50)))
				end
			end
		end

		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Kiro Sessions" })
	end, { desc = "List all Kiro terminal sessions" })

	-- Register config validation command
	vim.api.nvim_create_user_command("KiroCheckConfig", function()
		local Migrate = require("kiro.migrate")
		local valid, issues = Migrate.validate_schema(State.get_config() or {})

		if valid then
			vim.notify("✓ Configuration is valid", vim.log.levels.INFO, { title = "Kiro Config" })
		else
			local lines = { "Configuration Issues:", "" }
			for _, issue in ipairs(issues) do
				table.insert(lines, string.format("  • %s", issue.message))
				if issue.suggestion then
					table.insert(lines, string.format("		 → %s", issue.suggestion))
				end
			end
			vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN, { title = "Kiro Config" })
		end
	end, { desc = "Validate Kiro configuration" })

	-- Register command palette commands
	Commands.register_palette_commands(config)

	Logger.debug("Kiro initialized successfully")
end

--- Register a custom command
--- @param name string Command name (must be non-empty, PascalCase recommended)
--- @param prompt string|function Prompt text or function that returns prompt
--- @return boolean success True if registered successfully
--- @return string|nil error Error message if validation fails
function M.register_command(name, prompt)
	local Validate = lazy_require("kiro.validate")

	-- Validate parameters
	local valid, err = Validate.all({
		{ Validate.not_empty, name,   "name" },
		{ Validate.type,      prompt, { "string", "function" }, "prompt" },
	})

	if not valid then
		Logger.error("Invalid parameters: %s", { notify = true }, err)
		return false, err
	end

	if not State.is_initialized() then
		local err_msg = Constants.MESSAGES.NOT_INITIALIZED
		Logger.error(err_msg)
		return false, err_msg
	end

	Logger.debug("Registering command: %s", name)
	local Commands = lazy_require("kiro.commands")
	local Terminal = lazy_require("kiro.terminal")
	Commands.register(name, prompt, Terminal, State.get_config())
	return true, nil
end

--- Close the Kiro terminal
function M.close_terminal()
	Logger.debug("Closing terminal")
	lazy_require("kiro.terminal").close()
end

--- Clear the Kiro terminal (close and clear history)
function M.clear_terminal()
	Logger.debug("Clearing terminal")
	lazy_require("kiro.terminal").close()
	lazy_require("kiro.history").clear()
	Logger.info("Terminal cleared")
end

--- Resend the last message to Kiro
function M.resend()
	if not State.is_initialized() then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED, { notify = true })
		return
	end

	local Window = lazy_require("kiro.terminal.window")
	local last = Window.get_last_message()
	if last then
		Logger.debug("Resending last message")
		local Terminal = lazy_require("kiro.terminal")
		local result = Terminal.open(last, State.get_config())
		if not result.ok then
			Logger.error(Constants.MESSAGES.FAILED_TO_RESEND, { notify = true }, result.error or "unknown error")
		end
	else
		Logger.warn(Constants.MESSAGES.NO_PREVIOUS_MESSAGE, { notify = true })
	end
end

--- Get command history
--- @return string[] List of previous messages
function M.get_history()
	local History = lazy_require("kiro.history")
	return History.get_all()
end

--- Clear command history
function M.clear_history()
	local History = lazy_require("kiro.history")
	History.clear()
	Logger.info("Command history cleared")
end

--- Send a message from history
--- @param index number History index (1 = oldest, -1 = newest, must be non-zero)
--- @return boolean success True if sent successfully
--- @return string|nil error Error message if failed
function M.send_from_history(index)
	local Validate = lazy_require("kiro.validate")

	-- Validate parameters
	local valid, err = Validate.type(index, "number", "index")
	if not valid then
		Logger.error("Invalid parameters: %s", { notify = true }, err)
		return false, err
	end

	if index == 0 then
		local err_msg = "index cannot be 0 (use 1 for oldest, -1 for newest)"
		Logger.error(err_msg, { notify = true })
		return false, err_msg
	end

	if not State.is_initialized() then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED, { notify = true })
		return false, Constants.MESSAGES.NOT_INITIALIZED
	end

	local History = lazy_require("kiro.history")
	local history = History.get_all()

	if #history == 0 then
		Logger.warn("No command history", { notify = true })
		return false, "No command history"
	end

	if index < 0 then
		index = #history + index + 1
	end

	if index < 1 or index > #history then
		local err_msg = string.format("Invalid history index: %d (history size: %d)", index, #history)
		Logger.error(err_msg, { notify = true })
		return false, err_msg
	end

	local message = history[index]
	Logger.debug("Sending from history [%d]: %s", index, message)
	local Terminal = lazy_require("kiro.terminal")
	local result = Terminal.open(message, State.get_config())
	if not result.ok then
		Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, result.error or "unknown error")
		return false, result.error
	end
	return true, nil
end

--- Send message with multiple files as context
--- @param prompt string Prompt text (can be empty)
--- @param files string[] List of file paths (must be non-empty array)
--- @return boolean success True if sent successfully
--- @return string|nil error Error message if failed
function M.send_with_files(prompt, files)
	local Validate = lazy_require("kiro.validate")

	-- Validate parameters
	local valid, err = Validate.all({
		{ Validate.type, prompt, "string", "prompt" },
		{ Validate.type, files,  "table",  "files" },
	})

	if not valid then
		Logger.error("Invalid parameters: %s", { notify = true }, err)
		return false, err
	end

	if #files == 0 then
		local err_msg = "files array cannot be empty"
		Logger.error(err_msg, { notify = true })
		return false, err_msg
	end

	if not State.is_initialized() then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED, { notify = true })
		return false, Constants.MESSAGES.NOT_INITIALIZED
	end

	-- Expand glob patterns
	local expanded_files = {}
	for _, pattern in ipairs(files) do
		local matches = vim.fn.glob(pattern, false, true)
		if #matches == 0 then
			Logger.warn("No files matched pattern: %s", nil, pattern)
		else
			for _, file in ipairs(matches) do
				table.insert(expanded_files, file)
			end
		end
	end

	if #expanded_files == 0 then
		local err_msg = "No files found matching patterns"
		Logger.error(err_msg, { notify = true })
		return false, err_msg
	end

	Logger.debug("Expanded %d patterns to %d files", #files, #expanded_files)
	local Commands = lazy_require("kiro.commands")
	local Terminal = lazy_require("kiro.terminal")
	local result = Commands.send_with_files(prompt, expanded_files, Terminal, State.get_config())
	if not result.ok then
		Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, result.error or "unknown error")
		return false, result.error
	end
	return true, nil
end

--- Get LSP server status
--- @return table Status of all configured LSP servers
function M.lsp_status()
	return lazy_require("kiro.lsp").get_status()
end

--- Show LSP status in floating window
function M.lsp_show_status()
	lazy_require("kiro.lsp").show_status()
end

--- Detect available LSP servers
--- @return table Detected LSP servers
function M.lsp_detect()
	return lazy_require("kiro.lsp").detect_servers()
end

--- Set current terminal session
--- @param name string Session name (must be non-empty)
--- @return boolean success True if set successfully
--- @return string|nil error Error message if validation fails
function M.set_session(name)
	local Validate = lazy_require("kiro.validate")
	local valid, err = Validate.not_empty(name, "name")
	if not valid then
		Logger.error("Invalid parameters: %s", { notify = true }, err)
		return false, err
	end

	local Window = lazy_require("kiro.terminal.window")
	Window.set_session(name)
	return true, nil
end

--- Get current terminal session name
--- @return string name Current session name
function M.get_session()
	local Window = lazy_require("kiro.terminal.window")
	return Window.get_current_session()
end

--- List all terminal sessions
--- @return table<string, {active: boolean, last_message: string|nil}> sessions Map of session names to info
function M.list_sessions()
	local Window = lazy_require("kiro.terminal.window")
	return Window.list_sessions()
end

--- Close all terminal sessions
function M.close_all_sessions()
	local Window = lazy_require("kiro.terminal.window")
	Window.close_all()
end

return M

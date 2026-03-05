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
			Lsp.setup()
		end
	end

	vim.api.nvim_create_user_command("KiroBuffers", function()
		local Palette = require("kiro.palette")
		Palette.show_sessions()
	end, { desc = "List all Kiro terminal sessions" })
	
	-- Register KiroBuffers in command registry
	Commands.track_command("KiroBuffers", "")

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

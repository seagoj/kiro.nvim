--- Neovim plugin for Kiro AI chat integration
--- @class Kiro
local M = {}

-- Module cache for lazy loading
local _modules = {}

local function lazy_require(name)
	if not _modules[name] then
		_modules[name] = require(name)
	end
	return _modules[name]
end

-- Core modules (always loaded)
local Config = require("kiro.config")
local Commands = require("kiro.commands")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")
local State = require("kiro.state")
local Error = require("kiro.error")

-- ============================================================================
-- Setup & Initialization
-- ============================================================================

--- Setup the Kiro plugin with optional configuration
--- @param opts KiroConfigOptions|nil Configuration options
function M.setup(opts)
	-- Load and merge project config
	local merged_opts, project_err = Config.merge_with_project(opts)
	if project_err then
		Logger.warn("Project config error: %s", project_err)
	end

	-- Initialize config
	local result = Config.init(merged_opts)
	if not result.ok then
		Logger.error("Invalid config: %s", { notify = true }, result.error)
		return
	end
	local config = result.value

	-- Skip if already initialized (unless forced)
	if not config.force_setup and State.is_initialized() then
		return
	end

	-- Enable debug logging if requested
	if config.debug then
		Logger.enable(Constants.LOG_LEVELS.DEBUG)
		Logger.debug("Configuration: %s", vim.inspect(config))
	end

	State.set_config(config)
	State.set_initialized(true)

	-- Register default commands
	if config.register_default_commands then
		for name, prompt in pairs(config.default_commands) do
			M.register_command(name, prompt)
		end
	end

	-- Register custom commands
	for name, prompt in pairs(config.commands) do
		M.register_command(name, prompt)
	end

	-- Setup LSP if config exists
	local lsp_config_path = vim.fn.getcwd() .. "/.kiro/settings/lsp.json"
	if vim.fn.filereadable(lsp_config_path) == 1 then
		lazy_require("kiro.lsp").setup()
	end

	-- Register session browser command (unified: active + saved)
	vim.api.nvim_create_user_command("KiroBuffers", function()
		lazy_require("kiro.palette").show_sessions({ show_all = true })
	end, { desc = "List all Kiro sessions (active and saved)" })
	Commands.track_command("KiroBuffers", "")

	-- Register command palette commands
	Commands.register_palette_commands(config)
	
	-- Register session resume commands
	Commands.register_resume_commands()

	Logger.debug("Kiro initialized successfully")
end

-- ============================================================================
-- Command Registration
-- ============================================================================

--- Register a custom command
--- @param name string Command name (must be non-empty, PascalCase recommended)
--- @param prompt string|function Prompt text or function that returns prompt
--- @return boolean success True if registered successfully
--- @return string|nil error Error message if validation fails
function M.register_command(name, prompt)
	local Validate = lazy_require("kiro.validate")

	local valid, err = Validate.all({
		{ Validate.not_empty, name, "name" },
		{ Validate.type, prompt, { "string", "function" }, "prompt" },
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
	Commands.register(name, prompt, lazy_require("kiro.terminal"), State.get_config())
	return true, nil
end

-- ============================================================================
-- Terminal Management
-- ============================================================================

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

	local last = lazy_require("kiro.terminal.window").get_last_message()
	if not last then
		Logger.warn(Constants.MESSAGES.NO_PREVIOUS_MESSAGE, { notify = true })
		return
	end

	Logger.debug("Resending last message")
	local result = lazy_require("kiro.terminal").open(last, State.get_config())
	if not result.ok then
		Logger.error(Constants.MESSAGES.FAILED_TO_RESEND, { notify = true }, result.error or "unknown error")
	end
end

-- ============================================================================
-- Multi-File Context
-- ============================================================================

--- Send message with multiple files as context
--- @param prompt string Prompt text (can be empty)
--- @param files string[] List of file paths or glob patterns
--- @return boolean success True if sent successfully
--- @return string|nil error Error message if failed
function M.send_with_files(prompt, files)
	local Validate = lazy_require("kiro.validate")

	local valid, err = Validate.all({
		{ Validate.type, prompt, "string", "prompt" },
		{ Validate.type, files, "table", "files" },
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

	-- Expand glob patterns to actual files
	local expanded_files = {}
	for _, pattern in ipairs(files) do
		local matches = vim.fn.glob(pattern, false, true)
		if #matches == 0 then
			Logger.warn("No files matched pattern: %s", nil, pattern)
		else
			vim.list_extend(expanded_files, matches)
		end
	end

	if #expanded_files == 0 then
		local err_msg = "No files found matching patterns"
		Logger.error(err_msg, { notify = true })
		return false, err_msg
	end

	Logger.debug("Expanded %d patterns to %d files", #files, #expanded_files)
	local result = Commands.send_with_files(prompt, expanded_files, lazy_require("kiro.terminal"), State.get_config())
	if not result.ok then
		Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, result.error or "unknown error")
		return false, result.error
	end
	return true, nil
end

-- ============================================================================
-- LSP Integration
-- ============================================================================

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

-- ============================================================================
-- Session Management
-- ============================================================================

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

	lazy_require("kiro.terminal.window").set_session(name)
	return true, nil
end

--- Get current terminal session name
--- @return string name Current session name
function M.get_session()
	return lazy_require("kiro.terminal.window").get_current_session()
end

--- List all terminal sessions
--- @return table<string, {active: boolean, last_message: string|nil}> sessions Map of session names to info
function M.list_sessions()
	return lazy_require("kiro.terminal.window").list_sessions()
end

--- Close all terminal sessions
function M.close_all_sessions()
	lazy_require("kiro.terminal.window").close_all()
end

--- Resume last conversation
--- @return boolean success
--- @return string|nil error
function M.resume()
	local State = lazy_require("kiro.state")
	if not State.is_initialized() then
		return false, "Kiro not initialized. Call setup() first."
	end
	
	local config = State.get_config()
	local Shell = lazy_require("kiro.terminal.shell")
	local Terminal = lazy_require("kiro.terminal")
	
	local cmd = Shell.build_command("", config.profile, { resume = true })
	Logger.debug("Resuming last session: %s", cmd)
	
	local result = Terminal.open_with_command(cmd, config)
	if Error.is_err(result) then
		Logger.error(result.error, { notify = true })
		return false, result.error
	end
	
	return true
end

--- Open interactive session picker
--- @return boolean success
--- @return string|nil error
function M.resume_picker()
	local State = lazy_require("kiro.state")
	if not State.is_initialized() then
		return false, "Kiro not initialized. Call setup() first."
	end
	
	local config = State.get_config()
	local Shell = lazy_require("kiro.terminal.shell")
	local Terminal = lazy_require("kiro.terminal")
	
	local cmd = Shell.build_command("", config.profile, { resume_picker = true })
	Logger.debug("Opening session picker: %s", cmd)
	
	local result = Terminal.open_with_command(cmd, config)
	if Error.is_err(result) then
		Logger.error(result.error, { notify = true })
		return false, result.error
	end
	
	return true
end

--- List all saved sessions
--- @return table|nil sessions Array of session objects
--- @return string|nil error
function M.get_saved_sessions()
	local Shell = lazy_require("kiro.terminal.shell")
	local output = vim.fn.system(Constants.CLI.EXECUTABLE .. " " .. Constants.CLI.COMMAND .. " --list-sessions")
	
	if vim.v.shell_error ~= 0 then
		return nil, "Failed to list sessions: " .. output
	end
	
	local sessions = Shell.parse_sessions(output)
	return sessions
end

--- Delete a session by ID
--- @param session_id string Session ID to delete
--- @return boolean success
--- @return string|nil error
function M.delete_session(session_id)
	local Validate = lazy_require("kiro.validate")
	local valid, err = Validate.not_empty(session_id, "session_id")
	if not valid then
		return false, err
	end
	
	local cmd = string.format("%s %s --delete-session %s", 
		Constants.CLI.EXECUTABLE, Constants.CLI.COMMAND, session_id)
	Logger.debug("Deleting session: %s", cmd)
	
	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		return false, "Failed to delete session: " .. output
	end
	
	Logger.info("Session deleted: %s", session_id)
	return true
end

return M

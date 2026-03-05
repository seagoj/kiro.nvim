--- Command registration and context building
--- @class KiroCommands
local M = {}

local Constants = require("kiro.constants")
local Logger = require("kiro.logger")
local Error = require("kiro.error")

--- Registry of all registered commands
--- @type table<string, {name: string, prompt: string|function}>
local _registered_commands = {}

--- Build context string with current file and optional line range
--- @param opts table Command options with range information
--- @return ErrorResult
local function build_file_context(opts)
	local file = vim.fn.expand("%")
	if file == "" then
		-- Return empty context instead of error
		return Error.ok("")
	end

	if vim.fn.filereadable(file) == 0 then
		return Error.err(string.format(Constants.MESSAGES.FILE_NOT_READABLE, file), Error.codes.FILE_NOT_READABLE)
	end

	local size_kb = vim.fn.getfsize(file) / 1024
	if size_kb > Constants.LIMITS.MAX_FILE_SIZE_KB then
		return Error.err(
			string.format(Constants.MESSAGES.FILE_TOO_LARGE, math.floor(size_kb), Constants.LIMITS.MAX_FILE_SIZE_KB),
			Error.codes.FILE_TOO_LARGE
		)
	end

	if opts.range > 0 then
		local line_count = vim.api.nvim_buf_line_count(0)
		if opts.line1 < 1 or opts.line2 > line_count then
			return Error.err(
				string.format(Constants.MESSAGES.INVALID_RANGE, opts.line1, opts.line2, line_count),
				Error.codes.INVALID_RANGE
			)
		end
		Logger.debug("Building context for %s, lines %d-%d", file, opts.line1, opts.line2)
		return Error.ok(string.format("(file: %s, lines %d-%d)", file, opts.line1, opts.line2))
	end
	Logger.debug("Building context for %s", file)
	return Error.ok(string.format("(file: %s)", file))
end

--- Build context for multiple files
--- @param files string[] List of file paths
--- @return ErrorResult
local function build_multi_file_context(files)
	local contexts = {}

	for _, file in ipairs(files) do
		if vim.fn.filereadable(file) == 0 then
			return Error.err(string.format(Constants.MESSAGES.FILE_NOT_READABLE, file), Error.codes.FILE_NOT_READABLE)
		end

		local size_kb = vim.fn.getfsize(file) / 1024
		if size_kb > Constants.LIMITS.MAX_FILE_SIZE_KB then
			return Error.err(
				string.format(Constants.MESSAGES.FILE_TOO_LARGE, math.floor(size_kb), Constants.LIMITS.MAX_FILE_SIZE_KB),
				Error.codes.FILE_TOO_LARGE
			)
		end

		table.insert(contexts, string.format("(file: %s)", file))
	end

	Logger.debug("Building context for %d files", #files)
	return Error.ok(table.concat(contexts, " "))
end

--- Register a user command that opens Kiro chat with a prompt
--- @param name string Command name
--- @param prompt string|function Prompt text or function that returns prompt
--- @param terminal table Terminal module
--- @param config KiroConfigOptions Configuration options
function M.register(name, prompt, terminal, config)
	-- Add to registry
	_registered_commands[name] = {
		name = name,
		prompt = type(prompt) == "function" and "<function>" or prompt,
	}

	-- Special handling for KiroBuffer to support session argument
	if name == "KiroBuffer" then
		vim.api.nvim_create_user_command(name, function(opts)
			Logger.debug("Executing command: %s", name)
			
			-- Handle session argument
			if opts.args ~= "" then
				local State = require("kiro.state")
				local Window = require("kiro.terminal.window")
				Window.set_session(opts.args)
				Logger.debug("Switched to session: %s", opts.args)
			end
			
			local result = build_file_context(opts)
			
			if Error.is_err(result) then
				Logger.error(result.error, { notify = true })
				return
			end
			
			local context = result.value

			local message
			if type(prompt) == "function" then
				message = prompt(opts)
				if context ~= "" then
					message = message .. " " .. context
				end
			else
				if prompt ~= "" then
					message = context ~= "" and (prompt .. " " .. context) or prompt
				else
					message = context
				end
			end

			Logger.debug("Sending message: %s", message)
			local open_result = terminal.open(message, config)
			if Error.is_err(open_result) then
				Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, open_result.error)
			end
		end, { 
			range = true,
			nargs = "?",
			desc = "Open Kiro chat (optionally specify session name)",
			complete = function()
				local kiro = require("kiro")
				local sessions = kiro.list_sessions()
				local names = {}
				for name, _ in pairs(sessions) do
					table.insert(names, name)
				end
				return names
			end,
		})
		return
	end

	-- Standard command registration for other commands
	vim.api.nvim_create_user_command(name, function(opts)
		Logger.debug("Executing command: %s", name)
		local result = build_file_context(opts)
		
		if Error.is_err(result) then
			Logger.error(result.error, { notify = true })
			return
		end
		
		local context = result.value

		local message
		if type(prompt) == "function" then
			message = prompt(opts)
			if context ~= "" then
				message = message .. " " .. context
			end
		else
			if prompt ~= "" then
				message = context ~= "" and (prompt .. " " .. context) or prompt
			else
				message = context
			end
		end

		Logger.debug("Sending message: %s", message)
		local open_result = terminal.open(message, config)
		if Error.is_err(open_result) then
			Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, open_result.error)
		end
	end, { range = true })
end

--- Track a command in the registry (for commands created outside this module)
--- @param name string Command name
--- @param prompt string Prompt text
function M.track_command(name, prompt)
	_registered_commands[name] = {
		name = name,
		prompt = prompt,
	}
end

--- Send message with multiple files as context
--- @param prompt string Prompt text
--- @param files string[] List of file paths
--- @param terminal table Terminal module
--- @param config KiroConfigOptions Configuration options
--- @return ErrorResult
function M.send_with_files(prompt, files, terminal, config)
	Logger.debug("Sending with %d files", #files)
	local result = build_multi_file_context(files)
	
	if Error.is_err(result) then
		Logger.error(result.error, { notify = true })
		return result
	end

	local message = prompt == "" and result.value or prompt .. " " .. result.value
	Logger.debug("Sending message: %s", message)
	
	local open_result = terminal.open(message, config)
	if Error.is_err(open_result) then
		Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, open_result.error)
	end
	return open_result
end

--- Get all registered commands
--- @return table[] Array of command info {name: string, prompt: string}
function M.get_all_commands()
	local commands = {}
	for _, cmd in pairs(_registered_commands) do
		table.insert(commands, cmd)
	end
	table.sort(commands, function(a, b)
		return a.name < b.name
	end)
	return commands
end

--- Register palette commands
--- @param config KiroConfigOptions Configuration options
function M.register_palette_commands(config)
	local Palette = require("kiro.palette")

	vim.api.nvim_create_user_command("KiroCommands", function()
		Palette.show_commands()
	end, { desc = "Show Kiro command palette" })
end

return M

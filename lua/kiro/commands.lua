--- Command registration and context building
--- @class KiroCommands
local M = {}

local Constants = require("kiro.constants")
local Logger = require("kiro.logger")
local Error = require("kiro.error")

--- Build context string with current file and optional line range
--- @param opts table Command options with range information
--- @return ErrorResult
local function build_file_context(opts)
	local file = vim.fn.expand("%")
	if file == "" then
		return Error.err(Constants.MESSAGES.NO_FILE, Error.codes.NO_FILE)
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
	vim.api.nvim_create_user_command(name, function(opts)
		Logger.debug("Executing command: %s", name)
		local result = build_file_context(opts)
		local context = ""
		
		if Error.is_err(result) then
			Logger.error(result.error, { notify = true })
		else
			context = result.value
		end

		local message
		if type(prompt) == "function" then
			message = prompt(opts) .. " " .. context
		else
			message = prompt == "" and context or prompt .. " " .. context
		end

		Logger.debug("Sending message: %s", message)
		local open_result = terminal.open(message, config)
		if Error.is_err(open_result) then
			Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, { notify = true }, open_result.error)
		end
	end, { range = true })
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

return M

--- Command registration and context building
--- @class KiroCommands
local M = {}

local Constants = require("kiro.constants")
local Logger = require("kiro.logger")

--- Build context string with current file and optional line range
--- @param opts table Command options with range information
--- @return string|nil Context string or nil if validation fails
--- @return string|nil Error message if validation fails
local function build_file_context(opts)
	local file = vim.fn.expand("%")
	if file == "" then
		return nil, Constants.MESSAGES.NO_FILE
	end

	-- Validate file exists and is readable
	if vim.fn.filereadable(file) == 0 then
		return nil, string.format(Constants.MESSAGES.FILE_NOT_READABLE, file)
	end

	-- Validate line range if specified
	if opts.range > 0 then
		local line_count = vim.api.nvim_buf_line_count(0)
		if opts.line1 < 1 or opts.line2 > line_count then
			return nil, string.format(Constants.MESSAGES.INVALID_RANGE, opts.line1, opts.line2, line_count)
		end
		Logger.debug("Building context for %s, lines %d-%d", file, opts.line1, opts.line2)
		return string.format("(file: %s, lines %d-%d)", file, opts.line1, opts.line2), nil
	end
	Logger.debug("Building context for %s", file)
	return string.format("(file: %s)", file), nil
end

--- Register a user command that opens Kiro chat with a prompt
--- @param name string Command name
--- @param prompt string|function Prompt text or function that returns prompt
--- @param terminal table Terminal module
--- @param config KiroConfigOptions Configuration options
function M.register(name, prompt, terminal, config)
	vim.api.nvim_create_user_command(name, function(opts)
		Logger.debug("Executing command: %s", name)
		local context, err = build_file_context(opts)
		if err then
			Logger.error(err)
			context = "" -- context is not required
		end

		local message
		if type(prompt) == "function" then
			message = prompt(opts) .. " " .. context
		else
			message = prompt == "" and context or prompt .. " " .. context
		end

		Logger.debug("Sending message: %s", message)
		local success, open_err = terminal.open(message, config)
		if not success then
			Logger.error(Constants.MESSAGES.FAILED_TO_OPEN, open_err or "unknown error")
		end
	end, { range = true })
end

return M

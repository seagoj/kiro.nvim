--- Command registration and context building
--- @class KiroCommands
local M = {}

--- Build context string with current file and optional line range
--- @param opts table Command options with range information
--- @return string|nil Context string or nil if no file
local function build_file_context(opts)
	local file = vim.fn.expand("%")
	if file == "" then
		vim.notify("No file in current buffer", vim.log.levels.WARN)
		return
	end

	if opts.range > 0 then
		return string.format("(file: %s, lines %d-%d)", file, opts.line1, opts.line2)
	end
	return string.format("(file: %s)", file)
end

--- Register a user command that opens Kiro chat with a prompt
--- @param name string Command name
--- @param prompt string|function Prompt text or function that returns prompt
--- @param terminal table Terminal module
--- @param config table Configuration options
function M.register(name, prompt, terminal, config)
	vim.api.nvim_create_user_command(name, function(opts)
		local context = build_file_context(opts)
		if not context then
			return
		end

		local message
		if type(prompt) == "function" then
			message = prompt(opts) .. " " .. context
		else
			message = prompt == "" and context or prompt .. " " .. context
		end

		terminal.open(message, config)
	end, { range = true })
end

return M

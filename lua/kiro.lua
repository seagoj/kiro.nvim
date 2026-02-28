-- Neovim plugin for Kiro AI chat integration
local M = {}

local DEFAULT_CONFIG = {
	register_commands = false,
	split = "vsplit",
}

local state = {
	config = nil,
	initialized = false,
}

-- Escape single quotes for safe shell argument passing
local function escape_shell_arg(arg)
	return arg:gsub("'", "'\\''")
end

-- Build context string with current file and optional line range
local function build_file_context(opts)
	local file = vim.fn.expand("%")
	if file == "" then
		vim.notify("No file in current buffer", vim.log.levels.WARN)
		return nil
	end

	if opts.range > 0 then
		return string.format("(file: %s, lines %d-%d)", file, opts.line1, opts.line2)
	end
	return string.format("(file: %s)", file)
end

-- Open Kiro chat in a vertical split terminal with the given prompt and file context
local function open_kiro_chat(prompt, opts)
	local context = build_file_context(opts)
	if not context then
		return
	end
	local message = prompt == "" and context or prompt .. " " .. context
	if vim.fn.executable("kiro-cli") == 0 then
		vim.notify("kiro-cli not found", vim.log.levels.ERROR)
		return
	end
	vim.cmd(string.format("%s | terminal kiro-cli chat '%s'", state.config.split, escape_shell_arg(message)))
end

-- Register a user command that opens Kiro chat with a default prompt
function M.register_command(name, prompt)
	vim.api.nvim_create_user_command(name, function(opts)
		open_kiro_chat(prompt or "", opts)
	end, { range = true })
end

-- Validate configuration
local function validate_config(config)
	if config.register_commands and not type(config.register_commands) ~= "boolean" then
		return false, "register_commands from be a boolean"
	end
	if config.split and not vim.tbl_contains({ "split", "vsplit" }, config.split) then
		return false, "split must be one of split|vsplit"
	end

	return true
end

-- Setup all Kiro AI commands
function M.setup(opts)
	if state.initialized then
		return
	end
	local config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, opts or {})
	local valid, err = validate_config(config)
	if not valid then
		vim.notify(string.format("Invalid config: %s", err), vim.log.levels.ERROR)
		return
	end

	state.config = config
	state.initialized = true

	if state.register_commands then
		M.register_command("KiroBuffer", "")
		M.register_command("KiroChat", "")
		M.register_command("KiroExplain", "Explain the code in this context")
		M.register_command("KiroFix", "Fix code based on FIXME comment")
		M.register_command("KiroOptimize", "Refactor for optimization")
		M.register_command("KiroRefactor", "Refactor for readability")
	end
end

return M

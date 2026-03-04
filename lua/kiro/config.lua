--- Configuration management for Kiro plugin
--- @class KiroConfig
local M = {}

local Constants = require("kiro.constants")
local Error = require("kiro.error")

--- @class KiroConfigOptions User-provided configuration options
--- @field commands? table<string, string|function> Custom commands with prompts
--- @field default_commands? table<string, string> Default commands
--- @field register_default_commands? boolean Enable default commands (default: true)
--- @field split? "split"|"vsplit"|"float" Split direction (default: "vsplit")
--- @field reuse_terminal? boolean Reuse existing terminal (default: true)
--- @field auto_insert_mode? boolean Auto enter insert mode (default: true)
--- @field force_setup? boolean Force setup even if already initialized (default: false)
--- @field debug? boolean Enable debug logging (default: false)
--- @field keymaps? KiroKeymaps Buffer-local keymaps
--- @field terminal_size? number Size of terminal split in lines/columns (10-200)
--- @field profile? string kiro-cli profile name
--- @field history_size? number Maximum command history size (min: 1, default: 50)
--- @field enable_lsp? boolean Enable LSP integration (default: true)
--- @field use_toggleterm? boolean Use toggleterm.nvim if available (default: false)
--- @field float_opts? KiroFloatOpts Floating window options

--- @class KiroKeymaps Buffer-local keymap configuration
--- @field close? string|false Keymap to close terminal (default: "<C-q>")
--- @field resend? string|false Keymap to resend last message (default: "<C-r>")

--- @class KiroFloatOpts Floating window configuration
--- @field width? number Width as percentage of screen (0.0-1.0, default: 0.8)
--- @field height? number Height as percentage of screen (0.0-1.0, default: 0.8)
--- @field row? number Row position (default: centered)
--- @field col? number Column position (default: centered)

--- Default configuration values
--- @type KiroConfigOptions
M.defaults = {
	commands = {},
	default_commands = { KiroBuffer = "" },
	register_default_commands = true,
	split = Constants.SPLIT.VERTICAL,
	reuse_terminal = true,
	auto_insert_mode = true,
	force_setup = false,
	debug = false,
	keymaps = {
		close = Constants.DEFAULT_KEYMAPS.CLOSE,
		resend = Constants.DEFAULT_KEYMAPS.RESEND,
	},
	terminal_size = nil,
	profile = nil,
	history_size = 50,
	enable_lsp = true,
	use_toggleterm = false,
	float_opts = {
		width = 0.8,
		height = 0.8,
		row = nil,
		col = nil,
	},
}

--- Validate configuration options
--- @param config KiroConfigOptions Configuration to validate
--- @return string|nil Error message if invalid, nil if valid
local function validate(config)
	if config.register_default_commands ~= nil and type(config.register_default_commands) ~= "boolean" then
		return "register_default_commands must be a boolean"
	end
	if
		config.split ~= nil
		and not vim.tbl_contains(
			{ Constants.SPLIT.HORIZONTAL, Constants.SPLIT.VERTICAL, Constants.SPLIT.FLOAT },
			config.split
		)
	then
		return "split must be one of split|vsplit|float"
	end
	if config.reuse_terminal ~= nil and type(config.reuse_terminal) ~= "boolean" then
		return "reuse_terminal must be a boolean"
	end
	if config.auto_insert_mode ~= nil and type(config.auto_insert_mode) ~= "boolean" then
		return "auto_insert_mode must be a boolean"
	end
	if config.force_setup ~= nil and type(config.force_setup) ~= "boolean" then
		return "force_setup must be a boolean"
	end
	if config.debug ~= nil and type(config.debug) ~= "boolean" then
		return "debug must be a boolean"
	end
	if config.keymaps ~= nil and type(config.keymaps) ~= "table" then
		return "keymaps must be a table"
	end
	if config.terminal_size ~= nil and type(config.terminal_size) ~= "number" then
		return "terminal_size must be a number"
	end
	if
		config.terminal_size ~= nil
		and (
			config.terminal_size < Constants.LIMITS.MIN_TERMINAL_SIZE
			or config.terminal_size > Constants.LIMITS.MAX_TERMINAL_SIZE
		)
	then
		return string.format(
			"terminal_size must be between %d and %d",
			Constants.LIMITS.MIN_TERMINAL_SIZE,
			Constants.LIMITS.MAX_TERMINAL_SIZE
		)
	end
	if config.profile ~= nil and type(config.profile) ~= "string" then
		return "profile must be a string"
	end
	if config.history_size ~= nil and type(config.history_size) ~= "number" then
		return "history_size must be a number"
	end
	if config.history_size ~= nil and config.history_size < 1 then
		return "history_size must be at least 1"
	end
	if config.enable_lsp ~= nil and type(config.enable_lsp) ~= "boolean" then
		return "enable_lsp must be a boolean"
	end
	if config.use_toggleterm ~= nil and type(config.use_toggleterm) ~= "boolean" then
		return "use_toggleterm must be a boolean"
	end
	if config.float_opts ~= nil and type(config.float_opts) ~= "table" then
		return "float_opts must be a table"
	end
	return nil
end

--- Merge user options with defaults
--- @param opts KiroConfigOptions|nil User configuration options
--- @return KiroConfigOptions Merged configuration
local function merge(opts)
	return vim.tbl_deep_extend("force", M.defaults, opts or {})
end

--- Initialize configuration with validation
--- @param opts KiroConfigOptions|nil User configuration options
--- @return ErrorResult
function M.init(opts)
	local config = merge(opts)
	local err = validate(config)
	if err then
		return Error.err(err, Error.codes.CONFIG_INVALID)
	end
	return Error.ok(config)
end

return M

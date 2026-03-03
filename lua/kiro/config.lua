--- Configuration management for Kiro plugin
--- @class KiroConfig
local M = {}

local Constants = require("kiro.constants")

--- @class KiroConfigOptions
--- @field commands table<string, string|function>|nil Custom commands with prompts
--- @field default_commands table<string, string>|nil Default commands
--- @field register_default_commands boolean|nil Enable default commands
--- @field split string|nil Split direction: 'split' or 'vsplit'
--- @field reuse_terminal boolean|nil Reuse existing terminal
--- @field auto_insert_mode boolean|nil Auto enter insert mode
--- @field force_setup boolean|nil Force setup even if already initialized
--- @field debug boolean|nil Enable debug logging
--- @field keymaps table<string, string|boolean>|nil Buffer-local keymaps
--- @field terminal_size number|nil Size of terminal split
--- @field profile string|nil kiro-cli profile name
--- @field history_size number|nil Maximum command history size
--- @field use_toggleterm boolean|nil Use toggleterm.nvim if available

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
	use_toggleterm = false,
}

--- Validate configuration options
--- @param config KiroConfigOptions Configuration to validate
--- @return string|nil Error message if invalid, nil if valid
local function validate(config)
	if config.register_default_commands ~= nil and type(config.register_default_commands) ~= "boolean" then
		return "register_default_commands must be a boolean"
	end
	if
		config.split ~= nil and not vim.tbl_contains({ Constants.SPLIT.HORIZONTAL, Constants.SPLIT.VERTICAL }, config.split)
	then
		return "split must be one of split|vsplit"
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
	if config.use_toggleterm ~= nil and type(config.use_toggleterm) ~= "boolean" then
		return "use_toggleterm must be a boolean"
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
--- @return KiroConfigOptions config Merged configuration
--- @return string|nil err Error message if validation fails
function M.init(opts)
	local config = merge(opts)
	return config, validate(config)
end

return M

--- Configuration management for Kiro plugin
--- @class KiroConfig
local M = {}

--- Default configuration values
--- @type table
M.defaults = {
	commands = {},
	default_commands = { KiroBuffer = "" },
	register_default_commands = true,
	split = "vsplit",
	reuse_terminal = true,
	auto_insert_mode = true,
	force_setup = false,
	debug = false,
}

--- Validate configuration options
--- @param config table Configuration to validate
--- @return string|nil Error message if invalid, nil if valid
local function validate(config)
	if config.register_default_commands ~= nil and type(config.register_default_commands) ~= "boolean" then
		return "register_default_commands must be a boolean"
	end
	if config.split ~= nil and not vim.tbl_contains({ "split", "vsplit" }, config.split) then
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
	return nil
end

--- Merge user options with defaults
--- @param opts table|nil User configuration options
--- @return table Merged configuration
local function merge(opts)
	return vim.tbl_deep_extend("force", M.defaults, opts or {})
end

--- Initialize configuration with validation
--- @param opts table|nil User configuration options
--- @return table config Merged configuration
--- @return string|nil err Error message if validation fails
function M.init(opts)
	local config = merge(opts)
	return config, validate(config)
end

return M

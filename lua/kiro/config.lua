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
--- @field command_palette? boolean Enable command palette (default: true)
--- @field palette_backend? "telescope"|"builtin" Palette backend (default: "telescope")

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
	command_palette = true,
	palette_backend = "telescope",
	float_opts = {
		width = 0.8,
		height = 0.8,
		row = nil,
		col = nil,
	},
}

--- Validate configuration options with detailed error messages
--- @param config KiroConfigOptions Configuration to validate
--- @return string|nil error Error message if invalid, nil if valid
--- @return string|nil suggestion Suggestion to fix the error
local function validate(config)
	local Validate = require("kiro.validate")
	
	-- Boolean options
	for _, opt in ipairs({ "register_default_commands", "reuse_terminal", "auto_insert_mode", 
	                       "force_setup", "debug", "enable_lsp", "use_toggleterm", "command_palette" }) do
		if config[opt] ~= nil then
			local valid, err = Validate.type(config[opt], "boolean", opt)
			if not valid then
				return err, string.format("Try: %s = true or %s = false", opt, opt)
			end
		end
	end
	
	-- Split option
	if config.split ~= nil then
		local valid, err = Validate.one_of(
			config.split,
			{ Constants.SPLIT.HORIZONTAL, Constants.SPLIT.VERTICAL, Constants.SPLIT.FLOAT },
			"split"
		)
		if not valid then
			return err, "Try: split = 'vsplit' (vertical), 'split' (horizontal), or 'float'"
		end
	end
	
	-- Terminal size
	if config.terminal_size ~= nil then
		local valid, err = Validate.range(
			config.terminal_size,
			Constants.LIMITS.MIN_TERMINAL_SIZE,
			Constants.LIMITS.MAX_TERMINAL_SIZE,
			"terminal_size"
		)
		if not valid then
			return err, string.format("Try a value between %d and %d", 
				Constants.LIMITS.MIN_TERMINAL_SIZE, Constants.LIMITS.MAX_TERMINAL_SIZE)
		end
	end
	
	-- History size
	if config.history_size ~= nil then
		local valid, err = Validate.type(config.history_size, "number", "history_size")
		if not valid then
			return err, "Try: history_size = 50"
		end
		if config.history_size < 1 then
			return "history_size must be at least 1", "Try: history_size = 50"
		end
	end
	
	-- Palette backend
	if config.palette_backend ~= nil then
		local valid, err = Validate.one_of(config.palette_backend, { "telescope", "builtin" }, "palette_backend")
		if not valid then
			return err, "Try: palette_backend = 'telescope' or 'builtin'"
		end
	end
	
	-- Profile
	if config.profile ~= nil then
		local valid, err = Validate.type(config.profile, "string", "profile")
		if not valid then
			return err, "Try: profile = 'work' or profile = 'personal'"
		end
	end
	
	-- Keymaps
	if config.keymaps ~= nil then
		local valid, err = Validate.type(config.keymaps, "table", "keymaps")
		if not valid then
			return err, "Try: keymaps = { close = '<C-q>', resend = '<C-r>' }"
		end
	end
	
	-- Float options
	if config.float_opts ~= nil then
		local valid, err = Validate.type(config.float_opts, "table", "float_opts")
		if not valid then
			return err, "Try: float_opts = { width = 0.8, height = 0.8 }"
		end
		
		-- Validate float_opts fields
		for _, field in ipairs({ "width", "height" }) do
			if config.float_opts[field] ~= nil then
				local v, e = Validate.type(config.float_opts[field], "number", "float_opts." .. field)
				if not v then
					return e, string.format("Try: float_opts = { %s = 0.8 }", field)
				end
				if config.float_opts[field] <= 0 or config.float_opts[field] > 1 then
					return string.format("float_opts.%s must be between 0 and 1", field),
						string.format("Try: float_opts = { %s = 0.8 }", field)
				end
			end
		end
	end
	
	-- Commands validation
	if config.commands ~= nil then
		local valid, err = Validate.type(config.commands, "table", "commands")
		if not valid then
			return err, "Try: commands = { MyCommand = 'prompt text' }"
		end
	end
	
	return nil, nil
end

--- Merge user options with defaults
--- @param opts KiroConfigOptions|nil User configuration options
--- @return KiroConfigOptions Merged configuration
local function merge(opts)
	return vim.tbl_deep_extend("force", M.defaults, opts or {})
end

--- Initialize configuration with validation
--- @param opts KiroConfigOptions|nil User configuration options
--- @return ErrorResult result Config on success, error with suggestion on failure
function M.init(opts)
	local config = merge(opts)
	local err, suggestion = validate(config)
	if err then
		local full_error = suggestion and (err .. "\n  Suggestion: " .. suggestion) or err
		return Error.err(full_error, Error.codes.CONFIG_INVALID)
	end
	return Error.ok(config)
end

--- Load project-specific configuration from .kiro.lua
--- @param project_root string|nil Project root directory (default: cwd)
--- @return table|nil config Project config or nil if not found
--- @return string|nil error Error message if load failed
function M.load_project_config(project_root)
	project_root = project_root or vim.fn.getcwd()
	local config_path = project_root .. "/.kiro.lua"
	
	if vim.fn.filereadable(config_path) == 0 then
		return nil, nil -- Not an error, just no project config
	end
	
	local ok, result = pcall(dofile, config_path)
	if not ok then
		return nil, string.format("Failed to load .kiro.lua: %s", result)
	end
	
	if type(result) ~= "table" then
		return nil, ".kiro.lua must return a table"
	end
	
	return result, nil
end

--- Merge global and project configurations
--- @param global_opts KiroConfigOptions|nil Global configuration
--- @param project_root string|nil Project root directory
--- @return KiroConfigOptions config Merged configuration
--- @return string|nil error Error message if project config invalid
function M.merge_with_project(global_opts, project_root)
	local project_config, err = M.load_project_config(project_root)
	if err then
		return global_opts or {}, err
	end
	
	if not project_config then
		return global_opts or {}, nil
	end
	
	-- Project config takes precedence
	return vim.tbl_deep_extend("force", global_opts or {}, project_config), nil
end

return M

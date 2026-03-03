--- Neovim plugin for Kiro AI chat integration
--- @class Kiro
local M = {}

local Config = require("kiro.config")
local Terminal = require("kiro.terminal")
local Commands = require("kiro.commands")

local state = {
	config = nil,
	initialized = false,
}

--- Setup the Kiro plugin with optional configuration
--- @param opts table|nil Configuration options
--- @field opts.register_default_commands boolean|nil Enable default commands (default: true)
--- @field opts.split string|nil Split direction: 'split' or 'vsplit' (default: 'vsplit')
--- @field opts.commands table|nil Custom commands with prompts (default: {})
--- @field opts.reuse_terminal boolean|nil Reuse existing terminal (default: true)
--- @field opts.auto_insert_mode boolean|nil Auto enter insert mode (default: true)
function M.setup(opts)
	local config, err = Config.init(opts)
	if err ~= nil then
		vim.notify(string.format("Invalid config: %s", err), vim.log.levels.ERROR)
		return
	end
	if not config.force_setup and state.initialized then
		return
	end
	if config.debug then
		vim.notify(vim.inspect(config), vim.log.levels.DEBUG)
	end

	state.config = config
	state.initialized = true

	if config.register_default_commands then
		for name, prompt in pairs(config.default_commands) do
			M.register_command(name, prompt)
		end
	end

	for name, prompt in pairs(config.commands) do
		M.register_command(name, prompt)
	end
end

--- Register a custom command
--- @param name string Command name
--- @param prompt string|function Prompt text or function that returns prompt
function M.register_command(name, prompt)
	if not state.initialized then
		vim.notify("Kiro not initialized. Call setup() first", vim.log.levels.ERROR)
	end
	Commands.register(name, prompt, Terminal, state.config)
end

return M

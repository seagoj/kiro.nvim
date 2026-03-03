--- Neovim plugin for Kiro AI chat integration
--- @class Kiro
local M = {}

local Config = require("kiro.config")
local Terminal = require("kiro.terminal")
local Commands = require("kiro.commands")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")

local state = {
	config = nil,
	initialized = false,
}

--- Setup the Kiro plugin with optional configuration
--- @param opts KiroConfigOptions|nil Configuration options
function M.setup(opts)
	local config, err = Config.init(opts)
	if err ~= nil then
		Logger.error("Invalid config: %s", err)
		return
	end
	if not config.force_setup and state.initialized then
		return
	end

	-- Enable logging if debug mode is on
	if config.debug then
		Logger.enable(Constants.LOG_LEVELS.DEBUG)
		Logger.debug("Configuration: %s", vim.inspect(config))
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

	Logger.debug("Kiro initialized successfully")
end

--- Register a custom command
--- @param name string Command name
--- @param prompt string|function Prompt text or function that returns prompt
function M.register_command(name, prompt)
	if not state.initialized then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED)
		return
	end
	Logger.debug("Registering command: %s", name)
	Commands.register(name, prompt, Terminal, state.config)
end

--- Close the Kiro terminal
function M.close_terminal()
	Logger.debug("Closing terminal")
	Terminal.close()
end

--- Resend the last message to Kiro
function M.resend()
	if not state.initialized then
		Logger.error(Constants.MESSAGES.NOT_INITIALIZED)
		return
	end

	local Window = require("kiro.terminal.window")
	local last = Window.get_last_message()
	if last then
		Logger.debug("Resending last message")
		local success, err = Terminal.open(last, state.config)
		if not success then
			Logger.error(Constants.MESSAGES.FAILED_TO_RESEND, err or "unknown error")
		end
	else
		Logger.warn(Constants.MESSAGES.NO_PREVIOUS_MESSAGE)
	end
end

return M

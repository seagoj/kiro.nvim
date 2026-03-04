--- Centralized state management for Kiro plugin
--- Reduces coupling between modules by providing a single source of truth
--- @class KiroState
local M = {}

--- @class PluginState
--- @field config KiroConfigOptions|nil Current configuration
--- @field initialized boolean Whether plugin is initialized
--- @field debug boolean Debug mode enabled

--- @type PluginState
local plugin_state = {
	config = nil,
	initialized = false,
	debug = false,
}

--- Get plugin configuration
--- @return KiroConfigOptions|nil config Current configuration
function M.get_config()
	return plugin_state.config
end

--- Set plugin configuration
--- @param config KiroConfigOptions Configuration to set
function M.set_config(config)
	plugin_state.config = config
	plugin_state.debug = config.debug or false
end

--- Check if plugin is initialized
--- @return boolean initialized True if initialized
function M.is_initialized()
	return plugin_state.initialized
end

--- Set initialization state
--- @param initialized boolean Initialization state
function M.set_initialized(initialized)
	plugin_state.initialized = initialized
end

--- Check if debug mode is enabled
--- @return boolean debug True if debug enabled
function M.is_debug()
	return plugin_state.debug
end

--- Reset all state (useful for testing)
function M.reset()
	plugin_state.config = nil
	plugin_state.initialized = false
	plugin_state.debug = false
end

return M

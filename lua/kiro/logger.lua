--- Logging system for Kiro plugin
--- @class KiroLogger
local M = {}

local Constants = require("kiro.constants")

local state = {
	enabled = false,
	level = Constants.LOG_LEVELS.INFO,
}

--- Enable debug logging
--- @param level number|nil Log level (default: INFO)
function M.enable(level)
	state.enabled = true
	state.level = level or Constants.LOG_LEVELS.INFO
end

--- Disable debug logging
function M.disable()
	state.enabled = false
end

--- Check if logging is enabled for a level
--- @param level number Log level to check
--- @return boolean
local function should_log(level)
	return state.enabled and level >= state.level
end

--- Log a debug message
--- @param msg string Message to log
--- @param ... any Additional arguments for string.format
function M.debug(msg, ...)
	if should_log(Constants.LOG_LEVELS.DEBUG) then
		vim.notify(string.format("[Kiro Debug] " .. msg, ...), Constants.LOG_LEVELS.DEBUG)
	end
end

--- Log an info message
--- @param msg string Message to log
--- @param ... any Additional arguments for string.format
function M.info(msg, ...)
	if should_log(Constants.LOG_LEVELS.INFO) then
		vim.notify(string.format(msg, ...), Constants.LOG_LEVELS.INFO)
	end
end

--- Log a warning message
--- @param msg string Message to log
--- @param ... any Additional arguments for string.format
function M.warn(msg, ...)
	vim.notify(string.format(msg, ...), Constants.LOG_LEVELS.WARN)
end

--- Log an error message
--- @param msg string Message to log
--- @param ... any Additional arguments for string.format
function M.error(msg, ...)
	vim.notify(string.format(msg, ...), Constants.LOG_LEVELS.ERROR)
end

return M

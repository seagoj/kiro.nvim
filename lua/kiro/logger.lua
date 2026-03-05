--- Logging system for Kiro plugin
--- @class KiroLogger
local M = {}

local Constants = require("kiro.constants")

local state = {
	level = vim.log.levels.OFF or 999, -- Disabled by default
}

--- Enable debug logging
--- @param level number|nil Log level (default: INFO)
function M.enable(level)
	state.level = level or Constants.LOG_LEVELS.INFO
end

--- Disable debug logging
function M.disable()
	state.level = vim.log.levels.OFF or 999
end

--- Check if logging is enabled for a level
--- @param level number Log level to check
--- @return boolean
local function should_log(level)
	return level >= state.level
end

--- Log a debug message
--- @param msg string Message to log
--- @param opts table|nil Options: { notify = boolean, title = string }
--- @param ... any Additional arguments for string.format
function M.debug(msg, opts, ...)
	if should_log(Constants.LOG_LEVELS.DEBUG) then
		local formatted = string.format("[Kiro Debug] " .. msg, ...)

		if opts and opts.notify then
			vim.notify(formatted, vim.log.levels.DEBUG, { title = opts.title or "Kiro" })
		else
			vim.notify(formatted, Constants.LOG_LEVELS.DEBUG)
		end
	end
end

--- Log an info message
--- @param msg string Message to log
--- @param opts table|nil Options: { notify = boolean, title = string }
--- @param ... any Additional arguments for string.format
function M.info(msg, opts, ...)
	if should_log(Constants.LOG_LEVELS.INFO) then
		local formatted = string.format(msg, ...)

		if opts and opts.notify then
			vim.notify(formatted, vim.log.levels.INFO, { title = opts.title or "Kiro" })
		else
			vim.notify(formatted, Constants.LOG_LEVELS.INFO)
		end
	end
end

--- Log a warning message
--- @param msg string Message to log
--- @param opts table|nil Options: { notify = boolean, title = string }
--- @param ... any Additional arguments for string.format
function M.warn(msg, opts, ...)
	vim.notify(msg)
	vim.notify(vim.inspect(...))
	local formatted = string.format(msg, ...)

	-- Show user notification if requested, otherwise just log
	if opts and opts.notify then
		vim.notify(formatted, vim.log.levels.WARN, { title = opts.title or "Kiro" })
	else
		vim.notify(formatted, Constants.LOG_LEVELS.WARN)
	end
end

--- Log an error message
--- @param msg string Message to log
--- @param opts table|nil Options: { notify = boolean, title = string }
--- @param ... any Additional arguments for string.format
function M.error(msg, opts, ...)
	local formatted = string.format(msg, ...)

	-- Show user notification if requested, otherwise just log
	if opts and opts.notify then
		vim.notify(formatted, vim.log.levels.ERROR, { title = opts.title or "Kiro" })
	else
		vim.notify(formatted, Constants.LOG_LEVELS.ERROR)
	end
end

return M

--- Command history management
--- @class KiroHistory
local M = {}

local Constants = require("kiro.constants")
local Logger = require("kiro.logger")

--- @class HistoryState
--- @field messages string[] List of sent messages
--- @field max_size number Maximum history size
--- @field current_index number|nil Current position in history

--- @type HistoryState
local state = {
	messages = {},
	max_size = 50,
	current_index = nil,
}

--- Add a message to history
--- @param message string Message to add
function M.add(message)
	-- Don't add duplicates of the last message
	if #state.messages > 0 and state.messages[#state.messages] == message then
		return
	end

	table.insert(state.messages, message)

	-- Trim history if it exceeds max size
	if #state.messages > state.max_size then
		table.remove(state.messages, 1)
	end

	-- Reset index when new message is added
	state.current_index = nil

	Logger.debug("Added to history (total: %d)", #state.messages)
end

--- Get previous message in history
--- @return string|nil Previous message or nil if at start
function M.previous()
	if #state.messages == 0 then
		return nil
	end

	if state.current_index == nil then
		state.current_index = #state.messages
	elseif state.current_index > 1 then
		state.current_index = state.current_index - 1
	end

	return state.messages[state.current_index]
end

--- Get next message in history
--- @return string|nil Next message or nil if at end
function M.next()
	if #state.messages == 0 or state.current_index == nil then
		return nil
	end

	if state.current_index < #state.messages then
		state.current_index = state.current_index + 1
		return state.messages[state.current_index]
	end

	-- At the end, reset index
	state.current_index = nil
	return nil
end

--- Get all history
--- @return string[] List of messages
function M.get_all()
	return vim.deepcopy(state.messages)
end

--- Clear history
function M.clear()
	state.messages = {}
	state.current_index = nil
	Logger.debug("History cleared")
end

--- Get history size
--- @return number Number of messages in history
function M.size()
	return #state.messages
end

--- Set maximum history size
--- @param size number Maximum number of messages to keep
function M.set_max_size(size)
	if size < 1 then
		Logger.warn("History max_size must be at least 1")
		return
	end

	state.max_size = size

	-- Trim if current size exceeds new max
	while #state.messages > state.max_size do
		table.remove(state.messages, 1)
	end

	Logger.debug("History max_size set to %d", size)
end

return M

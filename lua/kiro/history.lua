--- Command history management
--- @class KiroHistory
local M = {}

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

--- Add a message to history (skips consecutive duplicates)
--- @param message string Message to add (must be non-empty)
--- @return boolean success True if added, false if duplicate or invalid
function M.add(message)
	if type(message) ~= "string" or message == "" then
		Logger.warn("Cannot add empty or non-string message to history")
		return false
	end
	
	-- Don't add duplicates of the last message
	if #state.messages > 0 and state.messages[#state.messages] == message then
		return false
	end

	table.insert(state.messages, message)

	-- Trim history if it exceeds max size
	if #state.messages > state.max_size then
		table.remove(state.messages, 1)
	end

	-- Reset index when new message is added
	state.current_index = nil

	Logger.debug("Added to history (total: %d)", #state.messages)
	return true
end

--- Get previous message in history (for navigation)
--- @return string|nil message Previous message or nil if at start
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

--- Get next message in history (for navigation)
--- @return string|nil message Next message or nil if at end
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

--- Get all history messages
--- @return string[] messages Copy of all messages (oldest to newest)
function M.get_all()
	return vim.deepcopy(state.messages)
end

--- Clear all history
function M.clear()
	state.messages = {}
	state.current_index = nil
	Logger.debug("History cleared")
end

--- Get current history size
--- @return number count Number of messages in history
function M.size()
	return #state.messages
end

--- Set maximum history size
--- @param size number Maximum messages to keep (must be >= 1)
--- @return boolean success True if set successfully
--- @return string|nil error Error message if invalid
function M.set_max_size(size)
	if type(size) ~= "number" then
		local err = "max_size must be a number"
		Logger.warn(err)
		return false, err
	end
	
	if size < 1 then
		local err = "max_size must be at least 1"
		Logger.warn(err)
		return false, err
	end

	state.max_size = size

	-- Trim if current size exceeds new max
	while #state.messages > state.max_size do
		table.remove(state.messages, 1)
	end

	Logger.debug("History max_size set to %d", size)
end

return M

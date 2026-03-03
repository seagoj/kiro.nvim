--- Window and buffer management for terminal sessions
--- @class KiroWindow
local M = {}

local Shell = require("kiro.terminal.shell")

local state = {
	bufnr = nil,
	winid = nil,
}

--- Check if terminal buffer is still valid
--- @return boolean True if buffer is valid
function M.is_buffer_valid()
	return state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)
end

--- Check if terminal window is still open
--- @return boolean True if window is valid
function M.is_window_valid()
	return state.winid and vim.api.nvim_win_is_valid(state.winid)
end

--- Focus existing terminal window or create new split
--- @param split_cmd string Split command ('split' or 'vsplit')
--- @return boolean True if terminal was focused or window created
function M.focus_or_create(split_cmd)
	if M.is_window_valid() then
		vim.api.nvim_set_current_win(state.winid)
		return true
	end

	if M.is_buffer_valid() then
		vim.cmd(split_cmd)
		vim.api.nvim_win_set_buf(0, state.bufnr)
		state.winid = vim.api.nvim_get_current_win()
		return true
	end

	return false
end

--- Send message to existing terminal
--- @param message string Message to send
--- @return boolean True if message was sent successfully
function M.send_message(message)
	if not M.is_buffer_valid() then
		return false
	end

	local escaped = Shell.escape_arg(message)
	vim.api.nvim_chan_send(vim.bo[state.bufnr].channel, escaped .. "\n")
	return true
end

--- Create new terminal with command
--- @param command string Shell command to execute
--- @param split_cmd string Split command ('split' or 'vsplit')
function M.create(command, split_cmd)
	vim.cmd(string.format("%s | terminal %s", split_cmd, command))
	state.bufnr = vim.api.nvim_get_current_buf()
	state.winid = vim.api.nvim_get_current_win()
end

--- Close and cleanup terminal
function M.close()
	if M.is_window_valid() then
		vim.api.nvim_win_close(state.winid, true)
	end
	state.bufnr = nil
	state.winid = nil
end

return M

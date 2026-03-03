--- Window and buffer management for terminal sessions
--- @class KiroWindow
local M = {}

local Shell = require("kiro.terminal.shell")
local Logger = require("kiro.logger")
local Constants = require("kiro.constants")

--- @class WindowState
--- @field bufnr number|nil Buffer number
--- @field winid number|nil Window ID
--- @field last_message string|nil Last sent message
--- @field name string Session name

--- @type table<string, WindowState>
local sessions = {}

--- @type string Current active session name
local current_session = "default"

--- Get or create session
--- @param name string|nil Session name (default: "default")
--- @return WindowState
local function get_session(name)
	name = name or current_session
	if not sessions[name] then
		sessions[name] = {
			bufnr = nil,
			winid = nil,
			last_message = nil,
			name = name,
		}
	end
	return sessions[name]
end

--- Set current session
--- @param name string Session name
function M.set_session(name)
	current_session = name
	Logger.debug("Switched to session: %s", name)
end

--- Get current session name
--- @return string
function M.get_current_session()
	return current_session
end

--- List all sessions
--- @return table<string, {active: boolean, last_message: string|nil}>
function M.list_sessions()
	local list = {}
	for name, state in pairs(sessions) do
		list[name] = {
			active = state.bufnr ~= nil and vim.api.nvim_buf_is_valid(state.bufnr),
			last_message = state.last_message,
		}
	end
	return list
end

--- Get last sent message
--- @param session_name string|nil Session name
--- @return string|nil Last message or nil
function M.get_last_message(session_name)
	local state = get_session(session_name)
	return state.last_message
end

--- Check if terminal buffer is still valid
--- @param session_name string|nil Session name
--- @return boolean True if buffer is valid
function M.is_buffer_valid(session_name)
	local state = get_session(session_name)
	return state.bufnr ~= nil and vim.api.nvim_buf_is_valid(state.bufnr)
end

--- Check if terminal window is still open
--- @param session_name string|nil Session name
--- @return boolean True if window is valid
function M.is_window_valid(session_name)
	local state = get_session(session_name)
	return state.winid ~= nil and vim.api.nvim_win_is_valid(state.winid)
end

--- Focus existing terminal window or create new split
--- @param split_cmd string Split command ('split', 'vsplit', or 'float')
--- @param config KiroConfigOptions Configuration options
--- @param session_name string|nil Session name
--- @return boolean True if terminal was focused or window created
function M.focus_or_create(split_cmd, config, session_name)
	local state = get_session(session_name)
	
	if state.winid and vim.api.nvim_win_is_valid(state.winid) then
		vim.api.nvim_set_current_win(state.winid)
		return true
	end

	if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
		if split_cmd == "float" then
			M.create_float_window(state.bufnr, config)
		else
			vim.cmd(split_cmd)
			vim.api.nvim_win_set_buf(0, state.bufnr)
		end
		state.winid = vim.api.nvim_get_current_win()
		return true
	end

	return false
end

--- Send message to existing terminal
--- @param message string Message to send
--- @param session_name string|nil Session name
--- @return boolean success True if message was sent successfully
--- @return string|nil error Error message if failed
function M.send_message(message, session_name)
	local state = get_session(session_name)
	
	if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
		return false, Constants.MESSAGES.TERMINAL_BUFFER_INVALID
	end

	local channel = vim.bo[state.bufnr].channel
	if channel == 0 then
		return false, Constants.MESSAGES.TERMINAL_CHANNEL_UNAVAILABLE
	end

	local ok, err = pcall(function()
		local escaped = Shell.escape_arg(message)
		vim.api.nvim_chan_send(channel, escaped .. "\n")
	end)

	if not ok then
		return false, string.format(Constants.MESSAGES.FAILED_TO_SEND, err)
	end

	state.last_message = message
	Logger.debug("Message sent to terminal (session: %s)", state.name)
	return true, nil
end

--- Create new terminal with command
--- @param command string Shell command to execute
--- @param split_cmd string Split command ('split', 'vsplit', or 'float')
--- @param config KiroConfigOptions Configuration options
--- @param session_name string|nil Session name
--- @return boolean success True if terminal was created successfully
--- @return string|nil error Error message if failed
function M.create(command, split_cmd, config, session_name)
	local state = get_session(session_name)
	
	local ok, err = pcall(function()
		if split_cmd == "float" then
			-- Create buffer first
			local bufnr = vim.api.nvim_create_buf(false, true)
			M.create_float_window(bufnr, config)
			vim.fn.termopen(command)
			state.bufnr = bufnr
			state.winid = vim.api.nvim_get_current_win()
		else
			-- Build split command with optional size
			local full_split_cmd = split_cmd
			if config.terminal_size then
				full_split_cmd = string.format("%s %d", split_cmd, config.terminal_size)
			end

			vim.cmd(string.format("%s | terminal %s", full_split_cmd, command))
			state.bufnr = vim.api.nvim_get_current_buf()
			state.winid = vim.api.nvim_get_current_win()
		end

		-- Set buffer name for identification
		vim.api.nvim_buf_set_name(state.bufnr, string.format("kiro://%s", state.name))

		-- Set up buffer-local keymaps
		if config and config.keymaps then
			M.setup_keymaps(config, session_name)
		end

		-- Set buffer options for better UX
		vim.bo[state.bufnr].buflisted = false -- luacheck: ignore
		vim.wo[state.winid].number = false -- luacheck: ignore
		vim.wo[state.winid].relativenumber = false -- luacheck: ignore

		-- Auto-cleanup on buffer delete
		vim.api.nvim_create_autocmd("BufDelete", {
			buffer = state.bufnr,
			once = true,
			callback = function()
				Logger.debug("Terminal buffer deleted (session: %s)", state.name)
				state.bufnr = nil
				state.winid = nil
			end,
		})

		Logger.debug("Terminal created: bufnr=%d, winid=%d, session=%s", state.bufnr, state.winid, state.name)
	end)

	if not ok then
		return false, string.format(Constants.MESSAGES.FAILED_TO_CREATE, err)
	end

	return true, nil
end

--- Create floating window with buffer
--- @param bufnr number Buffer number
--- @param config KiroConfigOptions Configuration options
function M.create_float_window(bufnr, config)
	local opts = config.float_opts or {}
	local ui = vim.api.nvim_list_uis()[1]

	local width = math.floor(ui.width * (opts.width or 0.8))
	local height = math.floor(ui.height * (opts.height or 0.8))
	local row = opts.row or math.floor((ui.height - height) / 2)
	local col = opts.col or math.floor((ui.width - width) / 2)

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	vim.api.nvim_open_win(bufnr, true, win_opts)
end

--- Setup buffer-local keymaps
--- @param config KiroConfigOptions Configuration with keymaps
--- @param session_name string|nil Session name
function M.setup_keymaps(config, session_name)
	local state = get_session(session_name)
	
	if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
		return
	end

	local opts = { buffer = state.bufnr, silent = true }

	if config.keymaps.close then
		vim.keymap.set("n", config.keymaps.close, function()
			M.close(session_name)
		end, vim.tbl_extend("force", opts, { desc = "Close Kiro terminal" }))
		Logger.debug("Keymap registered: %s -> close (session: %s)", config.keymaps.close, state.name)
	end

	if config.keymaps.resend then
		vim.keymap.set("n", config.keymaps.resend, function()
			local last = M.get_last_message(session_name)
			if last then
				M.send_message(last, session_name)
			else
				Logger.warn(Constants.MESSAGES.NO_PREVIOUS_MESSAGE)
			end
		end, vim.tbl_extend("force", opts, { desc = "Resend last message" }))
		Logger.debug("Keymap registered: %s -> resend (session: %s)", config.keymaps.resend, state.name)
	end
end

--- Close and cleanup terminal
--- @param session_name string|nil Session name
function M.close(session_name)
	local state = get_session(session_name)
	
	if state.winid and vim.api.nvim_win_is_valid(state.winid) then
		vim.api.nvim_win_close(state.winid, true)
	end
	
	if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
		vim.api.nvim_buf_delete(state.bufnr, { force = true })
	end
	
	state.bufnr = nil
	state.winid = nil
	Logger.debug("Terminal closed (session: %s)", state.name)
end

--- Close all terminal sessions
function M.close_all()
	for name, _ in pairs(sessions) do
		M.close(name)
	end
	Logger.debug("All terminal sessions closed")
end

return M

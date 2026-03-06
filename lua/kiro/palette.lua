--- Command palette with fallback support
--- @module kiro.palette
local M = {}

local Terminal = require("kiro.terminal")

--- Check if telescope is available
--- @return boolean
local function has_telescope()
	return pcall(require, "telescope")
end

--- Show sessions picker
--- @param opts table|nil Options
function M.show_sessions(opts)
	opts = opts or {}
	local show_saved = opts.show_saved or false
	local show_all = opts.show_all or false

	if has_telescope() then
		require("telescope").extensions.kiro.sessions(opts)
		return
	end

	-- Fallback to vim.ui.select
	local kiro = require("kiro")
	
	if show_all then
		-- Show both active and saved sessions
		local items = {}
		
		-- Add active terminal sessions
		local active_sessions = kiro.list_sessions()
		if vim.tbl_count(active_sessions) > 0 then
			table.insert(items, { type = "header", label = "Active Terminals" })
			for name, _ in pairs(active_sessions) do
				table.insert(items, { type = "active", name = name })
			end
		end
		
		-- Add saved sessions
		local saved_sessions, err = kiro.get_saved_sessions()
		if saved_sessions and #saved_sessions > 0 then
			if #items > 0 then
				table.insert(items, { type = "separator" })
			end
			table.insert(items, { type = "header", label = "Saved Conversations" })
			for _, session in ipairs(saved_sessions) do
				table.insert(items, { type = "saved", session = session })
			end
		end
		
		if #items == 0 then
			vim.notify("No sessions available", vim.log.levels.INFO)
			return
		end
		
		vim.ui.select(items, {
			prompt = "Select session:",
			format_item = function(item)
				if item.type == "header" then
					return "── " .. item.label .. " ──"
				elseif item.type == "separator" then
					return ""
				elseif item.type == "active" then
					return "  • " .. item.name
				elseif item.type == "saved" then
					return string.format("  • [%s] %s - %s (%d msgs)", 
						item.session.id:sub(1, 8), item.session.time_ago, 
						item.session.preview, item.session.msg_count)
				end
			end,
		}, function(choice)
			if not choice or choice.type == "header" or choice.type == "separator" then
				return
			end
			
			if choice.type == "active" then
				-- Open/focus the terminal for this session
				kiro.set_session(choice.name)
				local Terminal = require("kiro.terminal")
				Terminal.open("", require("kiro.state").get_config())
			elseif choice.type == "saved" then
				vim.notify("Resuming session: " .. choice.session.id:sub(1, 8), vim.log.levels.INFO)
				kiro.resume()
			end
		end)
		
	elseif show_saved then
		-- Show saved sessions from kiro-cli
		local sessions, err = kiro.get_saved_sessions()
		if not sessions then
			vim.notify("Failed to list sessions: " .. (err or "unknown error"), vim.log.levels.ERROR)
			return
		end
		
		if #sessions == 0 then
			vim.notify("No saved sessions found", vim.log.levels.INFO)
			return
		end
		
		vim.ui.select(sessions, {
			prompt = "Select session to resume:",
			format_item = function(item)
				return string.format("[%s] %s - %s (%d msgs)", 
					item.id:sub(1, 8), item.time_ago, item.preview, item.msg_count)
			end,
		}, function(choice)
			if choice then
				-- Resume with specific session ID
				vim.notify("Resuming session: " .. choice.id:sub(1, 8), vim.log.levels.INFO)
				kiro.resume()
			end
		end)
	else
		-- Show active terminal sessions
		local sessions = kiro.list_sessions()
		
		if vim.tbl_count(sessions) == 0 then
			vim.notify("No active sessions", vim.log.levels.INFO)
			return
		end

		-- Convert sessions table to array
		local session_list = {}
		for name, _ in pairs(sessions) do
			table.insert(session_list, name)
		end

		vim.ui.select(session_list, {
			prompt = "Select session:",
			format_item = function(item)
				return item
			end,
		}, function(choice)
			if choice then
				kiro.set_session(choice)
				vim.notify("Switched to session: " .. choice, vim.log.levels.INFO)
			end
		end)
	end
end

--- Show commands picker
--- @param opts table|nil Options
function M.show_commands(opts)
	opts = opts or {}

	if has_telescope() then
		require("telescope").extensions.kiro.commands(opts)
		return
	end

	-- Fallback to vim.ui.select
	local Commands = require("kiro.commands")
	local commands = Commands.get_all_commands()
	
	if #commands == 0 then
		vim.notify("No Kiro commands registered", vim.log.levels.INFO)
		return
	end

	vim.ui.select(commands, {
		prompt = "Select command:",
		format_item = function(item)
			local prompt_display = item.prompt ~= "" and (" - " .. item.prompt) or ""
			return item.name .. prompt_display
		end,
	}, function(choice)
		if choice then
			vim.cmd(choice.name)
		end
	end)
end

return M

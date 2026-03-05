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

	if has_telescope() then
		require("telescope").extensions.kiro.sessions(opts)
		return
	end

	-- Fallback to vim.ui.select
	local kiro = require("kiro")
	local sessions = kiro.list_sessions()
	
	if vim.tbl_count(sessions) == 0 then
		vim.notify("No sessions available", vim.log.levels.INFO)
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

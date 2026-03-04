--- Command palette with fallback support
--- @module kiro.palette
local M = {}

local History = require("kiro.history")
local Terminal = require("kiro.terminal")

--- Show history picker
--- @param opts table|nil Options
function M.show_history(opts)
	opts = opts or {}

	local telescope = require("kiro.telescope")
	if telescope.has_telescope() then
		require("telescope").extensions.kiro.history(opts)
		return
	end

	-- Fallback to vim.ui.select
	local history = History.get()
	if #history == 0 then
		vim.notify("No command history", vim.log.levels.INFO)
		return
	end

	vim.ui.select(history, {
		prompt = "Select command:",
		format_item = function(item)
			return item
		end,
	}, function(choice)
		if choice then
			require("kiro").send_from_history(choice)
		end
	end)
end

--- Show sessions picker
--- @param opts table|nil Options
function M.show_sessions(opts)
	opts = opts or {}

	local telescope = require("kiro.telescope")
	if telescope.has_telescope() then
		require("telescope").extensions.kiro.sessions(opts)
		return
	end

	-- Fallback to vim.ui.select
	local sessions = Terminal.get_sessions()
	if #sessions == 0 then
		vim.notify("No sessions available", vim.log.levels.INFO)
		return
	end

	vim.ui.select(sessions, {
		prompt = "Select session:",
		format_item = function(item)
			return item
		end,
	}, function(choice)
		if choice then
			Terminal.set_session(choice)
			vim.notify("Switched to session: " .. choice, vim.log.levels.INFO)
		end
	end)
end

--- Show search picker
--- @param opts table|nil Options
function M.show_search(opts)
	opts = opts or {}

	local telescope = require("kiro.telescope")
	if telescope.has_telescope() then
		require("telescope").extensions.kiro.search(opts)
		return
	end

	-- Fallback to vim.ui.select
	local history = History.get()
	if #history == 0 then
		vim.notify("No history to search", vim.log.levels.INFO)
		return
	end

	vim.ui.select(history, {
		prompt = "Search:",
		format_item = function(item)
			return item
		end,
	}, function() end)
end

return M

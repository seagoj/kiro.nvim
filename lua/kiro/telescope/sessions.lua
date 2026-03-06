--- Sessions picker for telescope
--- @module kiro.telescope.sessions
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

--- Create sessions picker
--- @param opts table|nil Telescope options
return function(opts)
	opts = opts or {}
	local show_saved = opts.show_saved or false
	local show_all = opts.show_all or false

	local kiro = require("kiro")

	if show_all then
		-- Show both active and saved sessions
		local items = {}

		-- Add active terminal sessions
		local active_sessions = kiro.list_sessions()
		for name, _ in pairs(active_sessions) do
			table.insert(items, { type = "active", name = name })
		end

		-- Add saved sessions
		local saved_sessions = kiro.get_saved_sessions()
		if saved_sessions then
			for _, session in ipairs(saved_sessions) do
				table.insert(items, { type = "saved", session = session })
			end
		end

		if #items == 0 then
			vim.notify("No sessions available", vim.log.levels.INFO)
			return
		end

		local displayer = entry_display.create({
			separator = " ",
			items = {
				{ width = 10 },
				{ width = 15 },
				{ remaining = true },
			},
		})

		pickers
			.new(opts, {
				prompt_title = "All Kiro Sessions",
				finder = finders.new_table({
					results = items,
					entry_maker = function(entry)
						local display_text, ordinal
						if entry.type == "active" then
							display_text = function()
								return displayer({
									{ "[Active]", "TelescopeResultsIdentifier" },
									{ entry.name, "TelescopeResultsVariable" },
									{ "", "TelescopeResultsComment" },
								})
							end
							ordinal = "active " .. entry.name
						else
							local s = entry.session
							display_text = function()
								return displayer({
									{ "[Saved]", "TelescopeResultsNumber" },
									{ s.time_ago, "TelescopeResultsComment" },
									{ string.format("%s (%d msgs)", s.preview, s.msg_count), "TelescopeResultsString" },
								})
							end
							ordinal = "saved " .. s.id .. " " .. s.preview
						end

						return {
							value = entry,
							display = display_text,
							ordinal = ordinal,
						}
					end,
				}),
				sorter = conf.generic_sorter(opts),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						if selection then
							if selection.value.type == "active" then
								-- Open/focus the terminal for this session
								kiro.set_session(selection.value.name)
								local Terminal = require("kiro.terminal")
								Terminal.open("", require("kiro.state").get_config())
							else
								vim.notify("Resuming session: " .. selection.value.session.id:sub(1, 8), vim.log.levels.INFO)
								kiro.resume()
							end
						end
					end)
					return true
				end,
			})
			:find()
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

		pickers
			.new(opts, {
				prompt_title = "Saved Kiro Sessions",
				finder = finders.new_table({
					results = sessions,
					entry_maker = function(entry)
						local display =
							string.format("[%s] %s - %s (%d msgs)", entry.id:sub(1, 8), entry.time_ago, entry.preview, entry.msg_count)
						return {
							value = entry,
							display = display,
							ordinal = entry.id .. " " .. entry.preview,
						}
					end,
				}),
				sorter = conf.generic_sorter(opts),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						if selection then
							vim.notify("Resuming session: " .. selection.value.id:sub(1, 8), vim.log.levels.INFO)
							kiro.resume()
						end
					end)
					return true
				end,
			})
			:find()
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

		pickers
			.new(opts, {
				prompt_title = "Active Kiro Sessions",
				finder = finders.new_table({
					results = session_list,
					entry_maker = function(entry)
						return {
							value = entry,
							display = entry,
							ordinal = entry,
						}
					end,
				}),
				sorter = conf.generic_sorter(opts),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						if selection then
							kiro.set_session(selection.value)
							vim.notify("Switched to session: " .. selection.value, vim.log.levels.INFO)
						end
					end)
					return true
				end,
			})
			:find()
	end
end

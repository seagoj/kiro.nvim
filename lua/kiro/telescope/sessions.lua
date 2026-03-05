--- Sessions picker for telescope
--- @module kiro.telescope.sessions
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

--- Create sessions picker
--- @param opts table|nil Telescope options
return function(opts)
	opts = opts or {}

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

	pickers
		.new(opts, {
			prompt_title = "Kiro Sessions",
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

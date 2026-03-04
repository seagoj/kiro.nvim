--- History picker for telescope
--- @module kiro.telescope.history
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local History = require("kiro.history")

--- Create history picker
--- @param opts table|nil Telescope options
return function(opts)
	opts = opts or {}

	local history = History.get()
	if #history == 0 then
		vim.notify("No command history", vim.log.levels.INFO)
		return
	end

	pickers
		.new(opts, {
			prompt_title = "Kiro Command History",
			finder = finders.new_table({
				results = history,
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
						require("kiro").send_from_history(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

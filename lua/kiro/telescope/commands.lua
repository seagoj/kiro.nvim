--- Telescope picker for Kiro commands
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

return function(opts)
	opts = opts or {}

	local Commands = require("kiro.commands")
	local commands = Commands.get_all_commands()

	if #commands == 0 then
		vim.notify("No Kiro commands registered", vim.log.levels.INFO)
		return
	end

	pickers
		.new(opts, {
			prompt_title = "Kiro Commands",
			finder = finders.new_table({
				results = commands,
				entry_maker = function(entry)
					local display = entry.name
					if entry.prompt ~= "" then
						display = display .. " - " .. entry.prompt
					end
					return {
						value = entry,
						display = display,
						ordinal = entry.name .. " " .. entry.prompt,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd(selection.value.name)
					end
				end)
				return true
			end,
		})
		:find()
end

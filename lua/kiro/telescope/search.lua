--- Search picker for telescope
--- @module kiro.telescope.search
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local History = require("kiro.history")

--- Create search picker
--- @param opts table|nil Telescope options
return function(opts)
	opts = opts or {}

	local history = History.get()
	if #history == 0 then
		vim.notify("No history to search", vim.log.levels.INFO)
		return
	end

	pickers
		.new(opts, {
			prompt_title = "Search Kiro History",
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
		})
		:find()
end

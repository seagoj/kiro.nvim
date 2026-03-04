--- Telescope extension for Kiro
--- @module kiro.telescope
local M = {}

--- Check if telescope is available
--- @return boolean
local function has_telescope()
	return pcall(require, "telescope")
end

--- Load telescope extension
--- @return table|nil
function M.load()
	if not has_telescope() then
		return nil
	end

	local telescope = require("telescope")
	return telescope.load_extension("kiro")
end

--- Setup telescope extension
--- @return table
function M.setup()
	if not has_telescope() then
		return {}
	end

	return require("telescope").register_extension({
		exports = {
			history = function(opts)
				return require("kiro.telescope.history")(opts)
			end,
			sessions = function(opts)
				return require("kiro.telescope.sessions")(opts)
			end,
			search = function(opts)
				return require("kiro.telescope.search")(opts)
			end,
		},
	})
end

M.has_telescope = has_telescope

return M

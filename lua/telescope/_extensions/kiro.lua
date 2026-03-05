--- Telescope extension for Kiro
return require("telescope").register_extension({
	exports = {
		sessions = function(opts)
			return require("kiro.telescope.sessions")(opts)
		end,
		commands = function(opts)
			return require("kiro.telescope.commands")(opts)
		end,
	},
})

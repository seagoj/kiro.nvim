-- Example project-specific Kiro configuration
-- Place this file at the root of your project as .kiro.lua
-- This config will be merged with your global Neovim config

return {
	-- Project-specific split preference
	split = "vsplit",

	-- Custom terminal size for this project
	terminal_size = 100,

	-- Project-specific profile
	profile = "work",

	-- Custom commands for this project
	commands = {
		-- Code review command
		KiroReview = "Review this code for best practices and potential issues in",

		-- Documentation command
		KiroDoc = "Generate comprehensive documentation for",

		-- Test generation
		KiroTest = "Generate unit tests for",

		-- Refactoring
		KiroRefactor = "Suggest refactoring improvements for",
	},

	-- Project-specific keymaps
	keymaps = {
		close = "<leader>kc",
		resend = "<leader>kr",
	},

	-- Floating window for focused work
	-- split = "float",
	-- float_opts = {
	--	 width = 0.9,
	--	 height = 0.9,
	-- },

	-- LSP integration is automatic if .kiro/settings/lsp.json exists
	-- To disable: delete .kiro/settings/lsp.json
	-- To enable: run 'kiro-cli /code init' in project root

	-- Use toggleterm if available
	-- use_toggleterm = true,
}

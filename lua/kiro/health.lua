--- Health check for Kiro plugin
--- @class KiroHealth
local M = {}

--- Check kiro-cli availability
--- @param health table Health API
local function check_kiro_cli(health)
	health.start("kiro-cli")
	if vim.fn.executable("kiro-cli") == 1 then
		local path = vim.fn.exepath("kiro-cli")
		health.ok(string.format("kiro-cli found in PATH: %s", path))
	else
		health.error("kiro-cli not found", { "Install from https://kiro.ai" })
	end
end

--- Check configuration
--- @param health table Health API
local function check_configuration(health)
	health.start("Configuration")

	local State = require("kiro.state")
	local config = State.get_config()

	if not config then
		health.warn("Plugin not initialized", { "Run require('kiro').setup()" })
		return
	end

	health.ok("All configuration options are valid")

	-- Display current configuration
	health.info(string.format("split: %s", config.split))
	health.info(string.format("auto_insert_mode: %s", tostring(config.auto_insert_mode)))
	health.info(string.format("register_default_commands: %s", tostring(config.register_default_commands)))
	health.info(string.format("use_toggleterm: %s", tostring(config.use_toggleterm)))

	if config.profile then
		health.info(string.format("profile: %s", config.profile))
	end

	if config.terminal_size then
		health.info(
			string.format("terminal_size: %d %s", config.terminal_size, config.split == "split" and "lines" or "columns")
		)
	end

	if config.float_opts then
		health.info(string.format("float_opts: width=%.1f, height=%.1f", config.float_opts.width, config.float_opts.height))
	end

	-- Show keymaps
	if config.keymaps.close then
		health.info(string.format("keymap close: %s", config.keymaps.close))
	end
	if config.keymaps.resend then
		health.info(string.format("keymap resend: %s", config.keymaps.resend))
	end
end

--- Check LSP integration
--- @param health table Health API
local function check_lsp(health)
	health.start("LSP Integration")

	local lsp_config_path = vim.fn.getcwd() .. "/.kiro/settings/lsp.json"
	if vim.fn.filereadable(lsp_config_path) ~= 1 then
		health.info("No LSP config found (run 'kiro-cli /code init' to enable)")
		return
	end

	health.ok(string.format("LSP config found: %s", lsp_config_path))

	-- Try to parse and show active servers
	local ok, content = pcall(vim.fn.readfile, lsp_config_path)
	if ok then
		local parse_ok, lsp_config = pcall(vim.json.decode, table.concat(content, "\n"))
		if parse_ok and type(lsp_config) == "table" then
			local servers = vim.tbl_keys(lsp_config)
			if #servers > 0 then
				health.ok(string.format("Configured servers: %s", table.concat(servers, ", ")))
			end
		else
			health.error("Failed to parse LSP config", { "Check JSON syntax in .kiro/settings/lsp.json" })
		end
	end
end

--- Check terminal backend
--- @param health table Health API
local function check_terminal_backend(health)
	health.start("Terminal Backend")

	local State = require("kiro.state")
	local config = State.get_config()

	if not config then
		return
	end

	if config.use_toggleterm then
		local has_toggleterm = pcall(require, "toggleterm")
		if has_toggleterm then
			health.ok("Using toggleterm.nvim backend")
		else
			health.warn("toggleterm.nvim not found, using default backend", {
				"Install toggleterm.nvim or set use_toggleterm = false",
			})
		end
	else
		health.ok("Using default terminal backend")
		local has_toggleterm = pcall(require, "toggleterm")
		if has_toggleterm then
			health.info("toggleterm.nvim available (set use_toggleterm = true to use)")
		end
	end
end

--- Check command registry
--- @param health table Health API
local function check_commands(health)
	health.start("Commands")

	local Commands = require("kiro.commands")
	local all_commands = Commands.get_all_commands()

	if #all_commands == 0 then
		health.warn("No commands registered")
		return
	end

	-- Count built-in vs custom
	local builtin = { "KiroBuffer", "KiroBuffers" }
	local builtin_count = 0
	local custom_count = 0
	local custom_names = {}

	for _, cmd in ipairs(all_commands) do
		local is_builtin = false
		for _, name in ipairs(builtin) do
			if cmd.name == name then
				is_builtin = true
				break
			end
		end

		if is_builtin then
			builtin_count = builtin_count + 1
		else
			custom_count = custom_count + 1
			table.insert(custom_names, cmd.name)
		end
	end

	health.ok(string.format("%d commands registered (%d built-in, %d custom)", #all_commands, builtin_count, custom_count))

	if #custom_names > 0 then
		health.info(string.format("Custom commands: %s", table.concat(custom_names, ", ")))
	end
end

--- Check project configuration
--- @param health table Health API
local function check_project_config(health)
	health.start("Project Configuration")

	local project_config_path = vim.fn.getcwd() .. "/.kiro.lua"
	if vim.fn.filereadable(project_config_path) == 1 then
		health.ok(string.format("Project config found: %s", project_config_path))

		-- Try to load it
		local ok, result = pcall(dofile, project_config_path)
		if ok and type(result) == "table" then
			health.ok("Project config is valid")

			-- Show some key settings
			if result.profile then
				health.info(string.format("Project profile: %s", result.profile))
			end
			if result.split then
				health.info(string.format("Project split: %s", result.split))
			end
		else
			health.error("Failed to load project config", {
				"Check Lua syntax in .kiro.lua",
				"Ensure it returns a table",
			})
		end
	else
		health.info("No project config (.kiro.lua not found)")
	end
end

--- Run health checks
function M.check()
	-- Support both new (0.10+) and old health API
	local health = vim.health or require("health")

	check_kiro_cli(health)
	check_configuration(health)
	check_lsp(health)
	check_terminal_backend(health)
	check_commands(health)
	check_project_config(health)
end

return M

--- LSP integration for Kiro plugin
--- @class KiroLsp
local M = {}

local Logger = require("kiro.logger")

--- @class LspServerConfig
--- @field cmd string[] Command to start the LSP server
--- @field filetypes string[] File types this server handles
--- @field root_dir string|nil Root directory pattern
--- @field capabilities table|nil LSP capabilities
--- @field init_options table|nil Initialization options

--- Track configured servers
--- @type table<string, LspServerConfig>
local configured_servers = {}

--- Track server status
--- @type table<string, {active: boolean, error: string|nil}>
local server_status = {}

--- Common LSP servers with their executables
local KNOWN_SERVERS = {
	lua_ls = { cmd = "lua-language-server", filetypes = { "lua" } },
	rust_analyzer = { cmd = "rust-analyzer", filetypes = { "rust" } },
	pyright = { cmd = "pyright-langserver", filetypes = { "python" } },
	tsserver = { cmd = "typescript-language-server", filetypes = { "typescript", "javascript" } },
	gopls = { cmd = "gopls", filetypes = { "go" } },
	clangd = { cmd = "clangd", filetypes = { "c", "cpp" } },
	jdtls = { cmd = "jdtls", filetypes = { "java" } },
	solargraph = { cmd = "solargraph", filetypes = { "ruby" } },
}

--- Check if an LSP server executable is available
--- @param cmd string|string[] Command or command array
--- @return boolean available
local function is_executable_available(cmd)
	if not cmd then
		return false
	end
	local executable = type(cmd) == "table" and cmd[1] or cmd
	if type(executable) ~= "string" then
		return false
	end
	return vim.fn.executable(executable) == 1
end

--- Auto-detect installed LSP servers
--- @return table<string, LspServerConfig> Detected servers
function M.detect_servers()
	local detected = {}

	for name, config in pairs(KNOWN_SERVERS) do
		if is_executable_available(config.cmd) then
			Logger.debug("Detected LSP server: %s", name)
			detected[name] = {
				cmd = { config.cmd },
				filetypes = config.filetypes,
				root_dir = vim.fn.getcwd(),
			}
		end
	end

	return detected
end

--- Parse and load LSP configuration from .kiro/settings/lsp.json
--- @return table|nil config LSP configuration or nil if not found
--- @return string|nil error Error message if loading fails
function M.load_config()
	local config_path = vim.fn.getcwd() .. "/.kiro/settings/lsp.json"

	if vim.fn.filereadable(config_path) == 0 then
		Logger.debug("LSP config not found at %s", config_path)
		return nil, nil
	end

	local file = io.open(config_path, "r")
	if not file then
		return nil, "Failed to open LSP config"
	end

	local content = file:read("*all")
	file:close()

	local ok, config = pcall(vim.json.decode, content)
	if not ok then
		return nil, "Failed to parse LSP config: " .. tostring(config)
	end

	-- Validate server executables
	for name, server_config in pairs(config) do
		if server_config and server_config.cmd and not is_executable_available(server_config.cmd) then
			local cmd_str = type(server_config.cmd) == "table" and server_config.cmd[1] or tostring(server_config.cmd)
			Logger.warn("LSP server '%s' executable not found: %s", name, cmd_str)
		end
	end

	Logger.debug("Loaded LSP config with %d servers", vim.tbl_count(config))
	return config, nil
end

--- Setup LSP servers from configuration
--- @param config table|nil LSP configuration (if nil, loads from file)
--- @return boolean success
function M.setup(config)
	if not config then
		local err
		config, err = M.load_config()
		if err then
			Logger.error("LSP setup failed: %s", { notify = true, title = "Kiro LSP" }, err)
			return false
		end
		if not config then
			Logger.debug("No LSP config found, skipping setup")
			return true
		end
	end

	for name, server_config in pairs(config) do
		configured_servers[name] = server_config
		M.setup_server(name, server_config)
	end

	Logger.info("LSP setup complete: %d servers configured", vim.tbl_count(configured_servers))
	return true
end

--- Setup a single LSP server
--- @param name string Server name
--- @param server_config LspServerConfig Server configuration
function M.setup_server(name, server_config)
	Logger.debug("Setting up LSP server: %s", name)

	-- Validate server config
	if not server_config or not server_config.cmd then
		local error_msg = string.format("LSP server '%s' has invalid configuration", name)
		Logger.error(error_msg)
		server_status[name] = { active = false, error = error_msg }
		return
	end

	-- Check if executable is available
	if not is_executable_available(server_config.cmd) then
		local cmd_str = type(server_config.cmd) == "table" and server_config.cmd[1] or tostring(server_config.cmd)
		local error_msg = string.format("LSP server '%s' not found: %s", name, cmd_str)
		Logger.error(error_msg)
		server_status[name] = { active = false, error = error_msg }
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = server_config.filetypes,
		callback = function()
			local ok, client_id = pcall(vim.lsp.start, {
				name = name,
				cmd = server_config.cmd,
				root_dir = server_config.root_dir or vim.fn.getcwd(),
				capabilities = server_config.capabilities,
				init_options = server_config.init_options,
			})

			if ok and client_id then
				server_status[name] = { active = true, error = nil }
				Logger.debug("LSP server '%s' started successfully (client_id: %d)", name, client_id)
			else
				local error_msg = string.format("Failed to start LSP server '%s'", name)
				server_status[name] = { active = false, error = error_msg }
				Logger.error(error_msg)
			end
		end,
	})

	-- Initialize status as configured but not active yet
	if not server_status[name] then
		server_status[name] = { active = false, error = nil }
	end
end

--- Get status of all configured LSP servers
--- @return table<string, {active: boolean, error: string|nil, config: LspServerConfig}>
function M.get_status()
	local status = {}
	for name, config in pairs(configured_servers) do
		status[name] = {
			active = server_status[name] and server_status[name].active or false,
			error = server_status[name] and server_status[name].error or nil,
			config = config,
		}
	end
	return status
end

--- Show LSP status in a floating window
function M.show_status()
	local status = M.get_status()

	if vim.tbl_count(status) == 0 then
		vim.notify("No LSP servers configured", vim.log.levels.INFO, { title = "Kiro LSP" })
		return
	end

	local lines = { "Kiro LSP Status", string.rep("=", 50), "" }

	for name, info in pairs(status) do
		local status_icon = info.active and "✓" or (info.error and "✗" or "○")
		local status_text = info.active and "Active" or (info.error and "Error" or "Configured")

		table.insert(lines, string.format("%s %s - %s", status_icon, name, status_text))

		if info.error then
			table.insert(lines, string.format("  Error: %s", info.error))
		end

		table.insert(lines, string.format("  Filetypes: %s", table.concat(info.config.filetypes, ", ")))
		table.insert(lines, string.format("  Command: %s", table.concat(info.config.cmd, " ")))
		table.insert(lines, "")
	end

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "kiro-lsp-status"

	-- Calculate window size
	local width = 60
	local height = #lines
	local ui = vim.api.nvim_list_uis()[1]
	
	-- Check if UI is available (not in headless mode)
	if not ui then
		-- Fallback to printing status
		print(table.concat(lines, "\n"))
		return
	end

	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)

	-- Open floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " Kiro LSP Status ",
		title_pos = "center",
	})

	-- Close on q or <Esc>
	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
	vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

return M

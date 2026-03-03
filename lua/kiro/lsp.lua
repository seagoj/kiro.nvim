--- LSP integration for Kiro plugin
--- @class KiroLsp
local M = {}

local Logger = require("kiro.logger")

--- @class LspServerConfig
--- @field cmd string[] Command to start the LSP server
--- @field filetypes string[] File types this server handles
--- @field root_dir string|nil Root directory pattern

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
			Logger.error("LSP setup failed: %s", err)
			return false
		end
		if not config then
			Logger.debug("No LSP config found, skipping setup")
			return true
		end
	end

	for name, server_config in pairs(config) do
		M.setup_server(name, server_config)
	end

	return true
end

--- Setup a single LSP server
--- @param name string Server name
--- @param server_config LspServerConfig Server configuration
function M.setup_server(name, server_config)
	Logger.debug("Setting up LSP server: %s", name)

	vim.api.nvim_create_autocmd("FileType", {
		pattern = server_config.filetypes,
		callback = function()
			vim.lsp.start({
				name = name,
				cmd = server_config.cmd,
				root_dir = server_config.root_dir or vim.fn.getcwd(),
			})
		end,
	})
end

return M

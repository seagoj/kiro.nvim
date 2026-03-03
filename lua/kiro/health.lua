--- Health check for Kiro plugin
--- @class KiroHealth
local M = {}

--- Run health checks
function M.check()
	vim.health.start("kiro.nvim")

	if vim.fn.executable("kiro-cli") == 1 then
		vim.health.ok("kiro-cli found in PATH")
	else
		vim.health.error("kiro-cli not found", { "Install from https://kiro.ai" })
	end
end

return M

--- Health check for Kiro plugin
--- @class KiroHealth
local M = {}

--- Run health checks
function M.check()
	-- Support both new (0.10+) and old health API
	local health = vim.health or require("health")
	
	health.start("kiro.nvim")

	if vim.fn.executable("kiro-cli") == 1 then
		health.ok("kiro-cli found in PATH")
	else
		health.error("kiro-cli not found", { "Install from https://kiro.ai" })
	end
end

return M

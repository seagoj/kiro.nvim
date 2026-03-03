-- Luacheck configuration for kiro.nvim
std = "lua51+luajit"

-- Neovim global variables
globals = {
	"vim",
}

-- Ignore warnings about line length
ignore = {
	"631", -- Line is too long
}

-- Read-only globals
read_globals = {
	"vim",
}

-- Exclude directories
exclude_files = {
	".git/",
	"node_modules/",
}

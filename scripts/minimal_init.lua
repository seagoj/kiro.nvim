-- Minimal init for testing
vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[set packpath=/tmp/nvim/site]])

local package_root = "/tmp/nvim/site/pack"
local install_path = package_root .. "/packer/start/plenary.nvim"

-- Auto-install plenary if not found
if vim.fn.isdirectory(install_path) == 0 then
	print("Installing plenary.nvim...")
	vim.fn.system({
		"git",
		"clone",
		"--depth=1",
		"https://github.com/nvim-lua/plenary.nvim",
		install_path,
	})
end

-- Add plenary to runtimepath
vim.opt.rtp:prepend(install_path)

-- Add plugin to runtimepath
vim.opt.rtp:append(".")

-- Load plenary
require("plenary.busted")

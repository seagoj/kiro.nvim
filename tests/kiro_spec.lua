local kiro = require("kiro")
local stub = require("luassert.stub")

describe("kiro.setup", function()
	before_each(function()
		-- Clean up any existing commands
		pcall(vim.api.nvim_del_user_command, "KiroBuffer")
		pcall(vim.api.nvim_del_user_command, "KiroTest")
	end)

	it("initializes with defaults", function()
		kiro.setup({ force_setup = true })
		assert.is_not_nil(vim.api.nvim_get_commands({}).KiroBuffer)
	end)

	it("respects register_default_commands = false", function()
		kiro.setup({ register_default_commands = false, force_setup = true })
		assert.is_nil(vim.api.nvim_get_commands({}).KiroBuffer)
	end)

	it("registers custom commands from config", function()
		kiro.setup({
			commands = { KiroTest = "Test" },
			force_setup = true,
		})
		assert.is_not_nil(vim.api.nvim_get_commands({}).KiroTest)
	end)

	it("validates split option", function()
		local notify_called = false
		local notify_stub = stub(vim, "notify")
		notify_stub.invokes(function(msg, level)
			if level == vim.log.levels.ERROR and msg:match("split") then
				notify_called = true
			end
		end)

		kiro.setup({ split = "invalid", force_setup = true })
		assert.is_true(notify_called)

		notify_stub:revert()
	end)
end)

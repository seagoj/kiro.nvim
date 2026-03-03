local kiro = require("kiro")
local stub = require("luassert.stub")

describe("kiro.setup", function()
	before_each(function()
		-- Clean up any existing commands
		pcall(vim.api.nvim_del_user_command, "KiroBuffer")
		pcall(vim.api.nvim_del_user_command, "KiroTest")
		pcall(vim.api.nvim_del_user_command, "KiroLspStatus")
		pcall(vim.api.nvim_del_user_command, "KiroSession")
		pcall(vim.api.nvim_del_user_command, "KiroSessions")
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

	it("returns error for missing kiro-cli", function()
		local Terminal = require("kiro.terminal")
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(0)

		local success, err = Terminal.open("test message", { split = "vsplit" })
		assert.is_false(success)
		assert.is_not_nil(err)
		assert.matches("kiro%-cli not found", err)

		executable_stub:revert()
	end)

	it("exposes close_terminal function", function()
		kiro.setup({ force_setup = true })
		assert.is_function(kiro.close_terminal)
	end)

	it("exposes resend function", function()
		kiro.setup({ force_setup = true })
		assert.is_function(kiro.resend)
	end)

	it("validates keymaps option", function()
		local notify_stub = stub(vim, "notify")
		local error_called = false
		notify_stub.invokes(function(msg, level)
			if level == vim.log.levels.ERROR and msg:match("keymaps") then
				error_called = true
			end
		end)

		kiro.setup({ keymaps = "invalid", force_setup = true })
		assert.is_true(error_called)

		notify_stub:revert()
	end)

	it("validates terminal_size option", function()
		local notify_stub = stub(vim, "notify")
		local error_called = false
		notify_stub.invokes(function(msg, level)
			if level == vim.log.levels.ERROR and msg:match("terminal_size") then
				error_called = true
			end
		end)

		kiro.setup({ terminal_size = "invalid", force_setup = true })
		assert.is_true(error_called)

		notify_stub:revert()
	end)

	it("validates profile option", function()
		local notify_stub = stub(vim, "notify")
		local error_called = false
		notify_stub.invokes(function(msg, level)
			if level == vim.log.levels.ERROR and msg:match("profile") then
				error_called = true
			end
		end)

		kiro.setup({ profile = 123, force_setup = true })
		assert.is_true(error_called)

		notify_stub:revert()
	end)

	it("exposes clear_terminal function", function()
		kiro.setup({ force_setup = true })
		assert.is_function(kiro.clear_terminal)
	end)

	it("exposes send_with_files function", function()
		kiro.setup({ force_setup = true })
		assert.is_function(kiro.send_with_files)
	end)
end)

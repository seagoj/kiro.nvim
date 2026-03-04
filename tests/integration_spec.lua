local Terminal = require("kiro.terminal")
local Window = require("kiro.terminal.window")
local Error = require("kiro.error")
local stub = require("luassert.stub")

describe("kiro.terminal integration", function()
	local config

	before_each(function()
		config = {
			split = "vsplit",
			reuse_terminal = true,
			auto_insert_mode = false,
		}
		Window.close()
	end)

	after_each(function()
		Window.close()
	end)

	it("opens terminal with kiro-cli command", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(1)

		local create_stub = stub(Window, "create")
		create_stub.returns(Error.ok())

		local send_stub = stub(Window, "send_message")
		send_stub.returns(Error.ok())

		local result = Terminal.open("test message", config)

		assert.is_true(Error.is_ok(result))
		assert.stub(create_stub).was_called()

		executable_stub:revert()
		create_stub:revert()
		send_stub:revert()
	end)

	it("returns error when kiro-cli not found", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(0)

		local result = Terminal.open("test message", config)

		assert.is_true(Error.is_err(result))
		assert.matches("kiro%-cli not found", result.error)

		executable_stub:revert()
	end)

	it("reuses existing terminal when configured", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(1)

		local focus_stub = stub(Window, "focus_or_create")
		focus_stub.returns(true)

		local send_stub = stub(Window, "send_message")
		send_stub.returns(Error.ok())

		local create_stub = stub(Window, "create")

		local result = Terminal.open("test message", config)

		assert.is_true(Error.is_ok(result))
		assert.stub(focus_stub).was_called()
		assert.stub(send_stub).was_called()
		assert.stub(create_stub).was_not_called()

		executable_stub:revert()
		focus_stub:revert()
		send_stub:revert()
		create_stub:revert()
	end)

	it("creates new terminal when reuse fails", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(1)

		local focus_stub = stub(Window, "focus_or_create")
		focus_stub.returns(true)

		local send_stub = stub(Window, "send_message")
		send_stub.returns(Error.err("Channel error", Error.codes.CHANNEL_UNAVAILABLE))

		local create_stub = stub(Window, "create")
		create_stub.returns(Error.ok())

		local result = Terminal.open("test message", config)

		assert.is_true(Error.is_ok(result))
		assert.stub(create_stub).was_called()

		executable_stub:revert()
		focus_stub:revert()
		send_stub:revert()
		create_stub:revert()
	end)

	it("does not reuse terminal when configured", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(1)

		local focus_stub = stub(Window, "focus_or_create")
		local create_stub = stub(Window, "create")
		create_stub.returns(Error.ok())

		config.reuse_terminal = false
		local result = Terminal.open("test message", config)

		assert.is_true(Error.is_ok(result))
		assert.stub(focus_stub).was_not_called()
		assert.stub(create_stub).was_called()

		executable_stub:revert()
		focus_stub:revert()
		create_stub:revert()
	end)

	it("propagates terminal creation errors", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(1)

		local create_stub = stub(Window, "create")
		create_stub.returns(Error.err("Failed to create window", Error.codes.CREATE_FAILED))

		local result = Terminal.open("test message", config)

		assert.is_true(Error.is_err(result))
		assert.matches("Failed to create window", result.error)

		executable_stub:revert()
		create_stub:revert()
	end)
end)

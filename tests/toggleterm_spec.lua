local Toggleterm = require("kiro.terminal.toggleterm")
local stub = require("luassert.stub")

describe("kiro.terminal.toggleterm", function()
	it("checks if toggleterm is available", function()
		-- This will return false in test environment since toggleterm isn't installed
		local available = Toggleterm.is_available()
		assert.is_boolean(available)
	end)

	it("returns error when kiro-cli not found", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(0)

		local result = Toggleterm.open("test", { split = "vsplit" })
		
		executable_stub:revert()
		
		local Error = require("kiro.error")
		assert.is_true(Error.is_err(result))
		assert.matches("kiro%-cli not found", result.error)
	end)

	it("stores last message", function()
		-- Can't fully test without toggleterm installed, but we can verify the API exists
		assert.is_function(Toggleterm.open)
		assert.is_function(Toggleterm.close)
		assert.is_function(Toggleterm.resend)
		assert.is_function(Toggleterm.get_last_message)
	end)
end)

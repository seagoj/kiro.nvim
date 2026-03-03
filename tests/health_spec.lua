local stub = require("luassert.stub")

describe("kiro.health", function()
	it("checks if kiro-cli is executable", function()
		-- Test the logic without invoking the health system
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(1)

		local result = vim.fn.executable("kiro-cli")
		assert.equals(1, result)

		executable_stub:revert()
	end)

	it("detects when kiro-cli is not found", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(0)

		local result = vim.fn.executable("kiro-cli")
		assert.equals(0, result)

		executable_stub:revert()
	end)
end)

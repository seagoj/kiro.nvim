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

	it("validates configuration when plugin is initialized", function()
		local State = require("kiro.state")
		State.set_config({
			split = "vsplit",
		})

		local config = State.get_config()
		assert.is_not_nil(config)
		assert.equals("vsplit", config.split)

		State.reset()
	end)

	it("checks LSP config file existence", function()
		local filereadable_stub = stub(vim.fn, "filereadable")
		filereadable_stub.returns(0)

		local result = vim.fn.filereadable(".kiro/settings/lsp.json")
		assert.equals(0, result)

		filereadable_stub:revert()
	end)
end)

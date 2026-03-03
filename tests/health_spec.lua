local Health = require("kiro.health")
local stub = require("luassert.stub")

describe("kiro.health", function()
	it("reports success when kiro-cli is found", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(1)

		local ok_called = false
		local ok_stub = stub(vim.health, "ok")
		ok_stub.invokes(function(msg)
			if msg:match("kiro%-cli found") then
				ok_called = true
			end
		end)

		Health.check()
		assert.is_true(ok_called)

		executable_stub:revert()
		ok_stub:revert()
	end)

	it("reports error when kiro-cli is not found", function()
		local executable_stub = stub(vim.fn, "executable")
		executable_stub.returns(0)

		local error_called = false
		local error_stub = stub(vim.health, "error")
		error_stub.invokes(function(msg)
			if msg:match("kiro%-cli not found") then
				error_called = true
			end
		end)

		Health.check()
		assert.is_true(error_called)

		executable_stub:revert()
		error_stub:revert()
	end)
end)

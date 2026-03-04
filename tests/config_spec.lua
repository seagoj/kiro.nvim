local Config = require("kiro.config")
local Error = require("kiro.error")

describe("kiro.config", function()
	it("returns defaults when no opts provided", function()
		local result = Config.init()
		assert.is_true(Error.is_ok(result))
		assert.equals("vsplit", result.value.split)
		assert.is_true(result.value.register_default_commands)
		assert.is_true(result.value.reuse_terminal)
		assert.is_true(result.value.auto_insert_mode)
	end)

	it("merges user options with defaults", function()
		local result = Config.init({ split = "split" })
		assert.is_true(Error.is_ok(result))
		assert.equals("split", result.value.split)
		assert.is_true(result.value.register_default_commands)
	end)

	it("validates split option", function()
		local result = Config.init({ split = "invalid" })
		assert.is_true(Error.is_err(result))
		assert.matches("split", result.error)
	end)

	it("accepts float split option", function()
		local result = Config.init({ split = "float" })
		assert.is_true(Error.is_ok(result))
		assert.equals("float", result.value.split)
	end)

	it("validates float_opts", function()
		local result = Config.init({
			split = "float",
			float_opts = { width = 0.9, height = 0.9 },
		})
		assert.is_true(Error.is_ok(result))
		assert.equals(0.9, result.value.float_opts.width)
		assert.equals(0.9, result.value.float_opts.height)
	end)

	it("validates boolean options", function()
		local result = Config.init({ reuse_terminal = "yes" })
		assert.is_true(Error.is_err(result))
		assert.matches("reuse_terminal", result.error)
	end)

	it("accepts valid configuration", function()
		local result = Config.init({
			split = "split",
			reuse_terminal = false,
			auto_insert_mode = false,
			register_default_commands = false,
		})
		assert.is_true(Error.is_ok(result))
		assert.equals("split", result.value.split)
		assert.is_false(result.value.reuse_terminal)
	end)
end)

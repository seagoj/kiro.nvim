local Config = require("kiro.config")

describe("kiro.config", function()
	it("returns defaults when no opts provided", function()
		local config, err = Config.init()
		assert.is_nil(err)
		assert.equals("vsplit", config.split)
		assert.is_true(config.register_default_commands)
		assert.is_true(config.reuse_terminal)
		assert.is_true(config.auto_insert_mode)
	end)

	it("merges user options with defaults", function()
		local config, err = Config.init({ split = "split" })
		assert.is_nil(err)
		assert.equals("split", config.split)
		assert.is_true(config.register_default_commands)
	end)

	it("validates split option", function()
		local _, err = Config.init({ split = "invalid" })
		assert.is_not_nil(err)
		assert.matches("split", err)
	end)

	it("accepts float split option", function()
		local config, err = Config.init({ split = "float" })
		assert.is_nil(err)
		assert.equals("float", config.split)
	end)

	it("validates float_opts", function()
		local config, err = Config.init({
			split = "float",
			float_opts = { width = 0.9, height = 0.9 },
		})
		assert.is_nil(err)
		assert.equals(0.9, config.float_opts.width)
		assert.equals(0.9, config.float_opts.height)
	end)

	it("validates boolean options", function()
		local _, err = Config.init({ reuse_terminal = "yes" })
		assert.is_not_nil(err)
		assert.matches("reuse_terminal", err)
	end)

	it("accepts valid configuration", function()
		local config, err = Config.init({
			split = "split",
			reuse_terminal = false,
			auto_insert_mode = false,
			register_default_commands = false,
		})
		assert.is_nil(err)
		assert.equals("split", config.split)
		assert.is_false(config.reuse_terminal)
	end)
end)

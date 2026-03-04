local Window = require("kiro.terminal.window")

describe("kiro.terminal.window", function()
	after_each(function()
		Window.close_all()
	end)

	it("reports invalid buffer initially", function()
		assert.is_false(Window.is_buffer_valid())
	end)

	it("reports invalid window initially", function()
		assert.is_false(Window.is_window_valid())
	end)

	it("creates terminal window", function()
		local config = { keymaps = { close = "<C-q>", resend = "<C-r>" } }
		Window.create("echo test", "vsplit", config)
		assert.is_true(Window.is_buffer_valid())
		assert.is_true(Window.is_window_valid())
	end)

	it("closes terminal window", function()
		local config = { keymaps = { close = "<C-q>", resend = "<C-r>" } }
		Window.create("echo test", "vsplit", config)
		Window.close()
		assert.is_false(Window.is_buffer_valid())
		assert.is_false(Window.is_window_valid())
	end)

	it("focus_or_create returns false when no buffer", function()
		assert.is_false(Window.focus_or_create("vsplit"))
	end)

	it("tracks last message", function()
		local config = { keymaps = { close = "<C-q>", resend = "<C-r>" } }
		Window.create("kiro-cli chat 'test'", "vsplit", config)

		Window.send_message("test message")
		assert.equals("test message", Window.get_last_message())

		Window.close()
		assert.is_nil(Window.get_last_message())
	end)
end)

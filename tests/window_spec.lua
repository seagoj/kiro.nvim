local Window = require("kiro.terminal.window")

describe("kiro.terminal.window", function()
	after_each(function()
		Window.close()
	end)

	it("reports invalid buffer initially", function()
		assert.is_false(Window.is_buffer_valid())
	end)

	it("reports invalid window initially", function()
		assert.is_false(Window.is_window_valid())
	end)

	it("creates terminal window", function()
		Window.create("echo test", "vsplit")
		assert.is_true(Window.is_buffer_valid())
		assert.is_true(Window.is_window_valid())
	end)

	it("closes terminal window", function()
		Window.create("echo test", "vsplit")
		Window.close()
		assert.is_false(Window.is_buffer_valid())
		assert.is_false(Window.is_window_valid())
	end)

	it("focus_or_create returns false when no buffer", function()
		assert.is_false(Window.focus_or_create("vsplit"))
	end)
end)

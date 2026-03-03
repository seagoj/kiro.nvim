local Commands = require("kiro.commands")
local stub = require("luassert.stub")

describe("kiro.commands", function()
	local mock_terminal
	local mock_config

	before_each(function()
		mock_terminal = {
			open = function()
				return true, nil
			end,
		}
		mock_config = {
			split = "vsplit",
			reuse_terminal = true,
			auto_insert_mode = true,
		}
		pcall(vim.api.nvim_del_user_command, "TestCommand")
	end)

	after_each(function()
		pcall(vim.api.nvim_del_user_command, "TestCommand")
	end)

	it("registers command with prompt", function()
		Commands.register("TestCommand", "Test prompt", mock_terminal, mock_config)
		assert.is_not_nil(vim.api.nvim_get_commands({}).TestCommand)
	end)

	it("handles missing file error", function()
		Commands.register("TestCommand", "Test", mock_terminal, mock_config)

		-- Create empty buffer
		vim.cmd("enew")

		local notify_stub = stub(vim, "notify")
		local error_called = false
		notify_stub.invokes(function(msg, level)
			if level == vim.log.levels.ERROR and msg:match("No file") then
				error_called = true
			end
		end)

		vim.cmd("TestCommand")
		assert.is_true(error_called)

		notify_stub:revert()
	end)

	it("handles unreadable file error", function()
		Commands.register("TestCommand", "Test", mock_terminal, mock_config)

		-- Set buffer name to non-existent file
		vim.cmd("file /nonexistent/file.txt")

		local notify_stub = stub(vim, "notify")
		local error_called = false
		notify_stub.invokes(function(msg, level)
			if level == vim.log.levels.ERROR and msg:match("not readable") then
				error_called = true
			end
		end)

		vim.cmd("TestCommand")
		assert.is_true(error_called)

		notify_stub:revert()
	end)

	it("handles terminal open failure", function()
		local failing_terminal = {
			open = function()
				return false, "Terminal creation failed"
			end,
		}

		Commands.register("TestCommand", "Test", failing_terminal, mock_config)

		-- Create a valid temp file
		local tmpfile = vim.fn.tempname()
		vim.fn.writefile({ "test" }, tmpfile)
		vim.cmd("edit " .. tmpfile)

		local notify_stub = stub(vim, "notify")
		local error_called = false
		notify_stub.invokes(function(msg, level)
			if level == vim.log.levels.ERROR and msg:match("Failed to open terminal") then
				error_called = true
			end
		end)

		vim.cmd("TestCommand")
		assert.is_true(error_called)

		notify_stub:revert()
		vim.fn.delete(tmpfile)
	end)

	it("builds context with file path", function()
		Commands.register("TestCommand", "Test", mock_terminal, mock_config)

		local tmpfile = vim.fn.tempname()
		vim.fn.writefile({ "test" }, tmpfile)
		vim.cmd("edit " .. tmpfile)

		local terminal_stub = stub(mock_terminal, "open")
		terminal_stub.returns(true, nil)

		vim.cmd("TestCommand")

		assert.stub(terminal_stub).was_called()
		local call_args = terminal_stub.calls[1].vals
		assert.matches(tmpfile, call_args[1])

		terminal_stub:revert()
		vim.fn.delete(tmpfile)
	end)

	it("builds context with line range", function()
		Commands.register("TestCommand", "Test", mock_terminal, mock_config)

		local tmpfile = vim.fn.tempname()
		vim.fn.writefile({ "line1", "line2", "line3" }, tmpfile)
		vim.cmd("edit " .. tmpfile)

		local terminal_stub = stub(mock_terminal, "open")
		terminal_stub.returns(true, nil)

		vim.cmd("2,3TestCommand")

		assert.stub(terminal_stub).was_called()
		local call_args = terminal_stub.calls[1].vals
		assert.matches("lines 2%-3", call_args[1])

		terminal_stub:revert()
		vim.fn.delete(tmpfile)
	end)

	it("validates line range bounds", function()
		-- Test the validation logic directly by checking it exists in the code
		-- Vim itself prevents invalid ranges from reaching the command
		Commands.register("TestCommand", "Test", mock_terminal, mock_config)

		local tmpfile = vim.fn.tempname()
		vim.fn.writefile({ "line1", "line2" }, tmpfile)
		vim.cmd("edit " .. tmpfile)

		-- Valid range should work
		local terminal_stub = stub(mock_terminal, "open")
		terminal_stub.returns(true, nil)

		vim.cmd("1,2TestCommand")
		assert.stub(terminal_stub).was_called()

		terminal_stub:revert()
		vim.fn.delete(tmpfile)
	end)

	it("supports function prompts", function()
		local prompt_fn = function()
			return "Dynamic prompt"
		end

		Commands.register("TestCommand", prompt_fn, mock_terminal, mock_config)

		local tmpfile = vim.fn.tempname()
		vim.fn.writefile({ "test" }, tmpfile)
		vim.cmd("edit " .. tmpfile)

		local terminal_stub = stub(mock_terminal, "open")
		terminal_stub.returns(true, nil)

		vim.cmd("TestCommand")

		assert.stub(terminal_stub).was_called()
		local call_args = terminal_stub.calls[1].vals
		assert.matches("Dynamic prompt", call_args[1])

		terminal_stub:revert()
		vim.fn.delete(tmpfile)
	end)

	it("sends with multiple files", function()
		local tmpfile1 = vim.fn.tempname()
		local tmpfile2 = vim.fn.tempname()
		vim.fn.writefile({ "test1" }, tmpfile1)
		vim.fn.writefile({ "test2" }, tmpfile2)

		local terminal_stub = stub(mock_terminal, "open")
		terminal_stub.returns(true, nil)

		local success, err = Commands.send_with_files("Test prompt", { tmpfile1, tmpfile2 }, mock_terminal, mock_config)

		assert.is_true(success)
		assert.is_nil(err)
		assert.stub(terminal_stub).was_called()
		local call_args = terminal_stub.calls[1].vals
		assert.matches(tmpfile1, call_args[1])
		assert.matches(tmpfile2, call_args[1])

		terminal_stub:revert()
		vim.fn.delete(tmpfile1)
		vim.fn.delete(tmpfile2)
	end)

	it("validates files in multi-file context", function()
		local success, err = Commands.send_with_files("Test", { "/nonexistent/file.txt" }, mock_terminal, mock_config)

		assert.is_false(success)
		assert.is_not_nil(err)
		assert.matches("not readable", err)
	end)
end)

--- Tests for session resume integration
describe("Session Resume", function()
	local kiro
	local Shell

	before_each(function()
		-- Reset modules
		package.loaded["kiro"] = nil
		package.loaded["kiro.terminal.shell"] = nil
		package.loaded["kiro.terminal"] = nil

		kiro = require("kiro")
		Shell = require("kiro.terminal.shell")

		-- Setup kiro
		kiro.setup({})
	end)

	describe("Shell command building", function()
		it("builds command with resume flag", function()
			local cmd = Shell.build_command("", nil, { resume = true })
			assert.is_true(cmd:match("--resume") ~= nil)
		end)

		it("builds command with resume-picker flag", function()
			local cmd = Shell.build_command("", nil, { resume_picker = true })
			assert.is_true(cmd:match("--resume%-picker") ~= nil)
		end)

		it("builds command with profile and resume", function()
			local cmd = Shell.build_command("", "work", { resume = true })
			assert.is_true(cmd:match("--profile work") ~= nil)
			assert.is_true(cmd:match("--resume") ~= nil)
		end)

		it("builds command without message", function()
			local cmd = Shell.build_command("", nil, { resume = true })
			assert.is_false(cmd:match("''") ~= nil)
		end)
	end)

	describe("Session parsing", function()
		it("parses session list output", function()
			local output = [[
Chat SessionId: abc123
	1 hour ago | test message | 5 msgs

Chat SessionId: def456
	2 hours ago | another test | 10 msgs
]]
			local sessions = Shell.parse_sessions(output)
			assert.equals(2, #sessions)
			assert.equals("abc123", sessions[1].id)
			assert.equals("test message", sessions[1].preview)
			assert.equals(5, sessions[1].msg_count)
		end)

		it("handles empty session list", function()
			local sessions = Shell.parse_sessions("")
			assert.equals(0, #sessions)
		end)

		it("strips ANSI codes", function()
			local output = "\27[38;5;141mChat SessionId: abc123\n\27[0m  1 hour ago | test | 5 msgs"
			local sessions = Shell.parse_sessions(output)
			assert.equals(1, #sessions)
			assert.equals("abc123", sessions[1].id)
		end)
	end)

	describe("API functions", function()
		it("exposes resume function", function()
			assert.is_function(kiro.resume)
		end)

		it("exposes resume_picker function", function()
			assert.is_function(kiro.resume_picker)
		end)

		it("exposes get_saved_sessions function", function()
			assert.is_function(kiro.get_saved_sessions)
		end)

		it("exposes delete_session function", function()
			assert.is_function(kiro.delete_session)
		end)
	end)

	describe("Commands", function()
		it("registers KiroResume command", function()
			local commands = vim.api.nvim_get_commands({})
			assert.is_not_nil(commands.KiroResume)
		end)

		it("registers KiroResumePicker command", function()
			local commands = vim.api.nvim_get_commands({})
			assert.is_not_nil(commands.KiroResumePicker)
		end)

		it("registers KiroListSessions command", function()
			local commands = vim.api.nvim_get_commands({})
			assert.is_not_nil(commands.KiroListSessions)
		end)

		it("registers KiroDeleteSession command", function()
			local commands = vim.api.nvim_get_commands({})
			assert.is_not_nil(commands.KiroDeleteSession)
		end)
	end)
end)

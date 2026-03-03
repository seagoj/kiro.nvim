--- Constants used throughout the plugin
--- @class KiroConstants
local M = {}

--- Log levels
M.LOG_LEVELS = {
	DEBUG = vim.log.levels.DEBUG,
	INFO = vim.log.levels.INFO,
	WARN = vim.log.levels.WARN,
	ERROR = vim.log.levels.ERROR,
}

--- Split commands
M.SPLIT = {
	HORIZONTAL = "split",
	VERTICAL = "vsplit",
}

--- Default keymaps
M.DEFAULT_KEYMAPS = {
	CLOSE = "<C-q>",
	RESEND = "<C-r>",
}

--- Messages
M.MESSAGES = {
	LOADING = "Sending to Kiro...",
	SENT = "Message sent",
	NO_FILE = "No file in current buffer",
	FILE_NOT_READABLE = "File not readable: %s",
	INVALID_RANGE = "Invalid line range: %d-%d (file has %d lines)",
	KIRO_CLI_NOT_FOUND = "kiro-cli not found in PATH",
	NOT_INITIALIZED = "Kiro not initialized. Call setup() first",
	TERMINAL_REUSE_FAILED = "Failed to send to existing terminal, creating new one",
	NO_PREVIOUS_MESSAGE = "No previous message to resend",
	TERMINAL_BUFFER_INVALID = "Terminal buffer is no longer valid",
	TERMINAL_CHANNEL_UNAVAILABLE = "Terminal channel is not available",
	FAILED_TO_SEND = "Failed to send message: %s",
	FAILED_TO_CREATE = "Failed to create terminal: %s",
	FAILED_TO_OPEN = "Failed to open terminal: %s",
	FAILED_TO_RESEND = "Failed to resend: %s",
}

--- Validation limits
M.LIMITS = {
	MIN_TERMINAL_SIZE = 1,
	MAX_TERMINAL_SIZE = 999,
}

--- CLI commands
M.CLI = {
	EXECUTABLE = "kiro-cli",
	COMMAND = "chat",
	PROFILE_FLAG = "--profile",
}

return M

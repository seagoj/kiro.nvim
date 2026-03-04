--- Standardized error handling for Kiro plugin
--- @class KiroError
local M = {}

--- @class ErrorResult Result of an operation that may fail
--- @field ok boolean True if operation succeeded, false if failed
--- @field value any|nil Return value on success (nil on error)
--- @field error string|nil Error message on failure (nil on success)
--- @field code string|nil Error code for programmatic handling (nil on success)

--- @enum ErrorCode
--- Error codes for programmatic handling
M.codes = {
	NO_FILE = "NO_FILE",
	FILE_NOT_READABLE = "FILE_NOT_READABLE",
	FILE_TOO_LARGE = "FILE_TOO_LARGE",
	INVALID_RANGE = "INVALID_RANGE",
	TERMINAL_INVALID = "TERMINAL_INVALID",
	CHANNEL_UNAVAILABLE = "CHANNEL_UNAVAILABLE",
	SEND_FAILED = "SEND_FAILED",
	CREATE_FAILED = "CREATE_FAILED",
	CLI_NOT_FOUND = "CLI_NOT_FOUND",
	CONFIG_INVALID = "CONFIG_INVALID",
	LSP_PARSE_FAILED = "LSP_PARSE_FAILED",
}

--- Create success result
--- @param value any|nil Optional return value
--- @return ErrorResult result Success result with value
function M.ok(value)
	return { ok = true, value = value, error = nil, code = nil }
end

--- Create error result
--- @param message string Error message describing what went wrong
--- @param code string|nil Error code from M.codes for programmatic handling
--- @return ErrorResult result Error result with message and code
function M.err(message, code)
	return { ok = false, value = nil, error = message, code = code }
end

--- Wrap a function call with error handling
--- @param fn function Function to execute
--- @param error_message string|nil Custom error message (uses pcall error if nil)
--- @param error_code string|nil Error code from M.codes
--- @return ErrorResult result Success with function return value or error
function M.wrap(fn, error_message, error_code)
	local ok, result = pcall(fn)
	if ok then
		return M.ok(result)
	end
	return M.err(error_message or tostring(result), error_code)
end

--- Check if result is success
--- @param result ErrorResult Result to check
--- @return boolean is_ok True if operation succeeded
function M.is_ok(result)
	return result.ok == true
end

--- Check if result is error
--- @param result ErrorResult Result to check
--- @return boolean is_err True if operation failed
function M.is_err(result)
	return result.ok == false
end

--- Unwrap result or return default value
--- @param result ErrorResult Result to unwrap
--- @param default any Default value if error
--- @return any value Result value if ok, default if error
function M.unwrap_or(result, default)
	return result.ok and result.value or default
end

return M

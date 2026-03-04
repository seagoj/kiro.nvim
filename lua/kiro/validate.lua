--- Parameter validation utilities
--- @class KiroValidate
local M = {}

--- Validate that a value is of expected type
--- @param value any Value to validate
--- @param expected_type string|string[] Expected type(s)
--- @param param_name string Parameter name for error messages
--- @return boolean valid True if valid
--- @return string|nil error Error message if invalid
function M.type(value, expected_type, param_name)
	local actual_type = type(value)
	local types = type(expected_type) == "table" and expected_type or { expected_type }
	
	for _, t in ipairs(types) do
		if actual_type == t then
			return true, nil
		end
	end
	
	local expected_str = table.concat(types, " or ")
	return false, string.format("%s must be %s, got %s", param_name, expected_str, actual_type)
end

--- Validate that a string is not empty
--- @param value string Value to validate
--- @param param_name string Parameter name for error messages
--- @return boolean valid True if valid
--- @return string|nil error Error message if invalid
function M.not_empty(value, param_name)
	if type(value) ~= "string" then
		return false, string.format("%s must be a string", param_name)
	end
	if value == "" then
		return false, string.format("%s cannot be empty", param_name)
	end
	return true, nil
end

--- Validate that a value is one of allowed options
--- @param value any Value to validate
--- @param options table List of allowed values
--- @param param_name string Parameter name for error messages
--- @return boolean valid True if valid
--- @return string|nil error Error message if invalid
function M.one_of(value, options, param_name)
	for _, opt in ipairs(options) do
		if value == opt then
			return true, nil
		end
	end
	
	local opts_str = table.concat(vim.tbl_map(function(o) return string.format("'%s'", o) end, options), ", ")
	return false, string.format("%s must be one of: %s (got '%s')", param_name, opts_str, tostring(value))
end

--- Validate that a number is within range
--- @param value number Value to validate
--- @param min number Minimum value (inclusive)
--- @param max number Maximum value (inclusive)
--- @param param_name string Parameter name for error messages
--- @return boolean valid True if valid
--- @return string|nil error Error message if invalid
function M.range(value, min, max, param_name)
	if type(value) ~= "number" then
		return false, string.format("%s must be a number", param_name)
	end
	if value < min or value > max then
		return false, string.format("%s must be between %d and %d (got %d)", param_name, min, max, value)
	end
	return true, nil
end

--- Validate that a table has required keys
--- @param value table Table to validate
--- @param required_keys string[] Required keys
--- @param param_name string Parameter name for error messages
--- @return boolean valid True if valid
--- @return string|nil error Error message if invalid
function M.has_keys(value, required_keys, param_name)
	if type(value) ~= "table" then
		return false, string.format("%s must be a table", param_name)
	end
	
	for _, key in ipairs(required_keys) do
		if value[key] == nil then
			return false, string.format("%s is missing required key '%s'", param_name, key)
		end
	end
	
	return true, nil
end

--- Validate that a value is callable (function or table with __call)
--- @param value any Value to validate
--- @param param_name string Parameter name for error messages
--- @return boolean valid True if valid
--- @return string|nil error Error message if invalid
function M.callable(value, param_name)
	local t = type(value)
	if t == "function" then
		return true, nil
	end
	if t == "table" and type(getmetatable(value).__call) == "function" then
		return true, nil
	end
	return false, string.format("%s must be a function or callable table", param_name)
end

--- Validate multiple conditions (all must pass)
--- @param validations table[] List of {validator_fn, ...args}
--- @return boolean valid True if all valid
--- @return string|nil error First error message if any invalid
function M.all(validations)
	for _, validation in ipairs(validations) do
		local fn = table.remove(validation, 1)
		local valid, err = fn(unpack(validation))
		if not valid then
			return false, err
		end
	end
	return true, nil
end

return M

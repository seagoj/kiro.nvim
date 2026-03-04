--- Configuration migration helpers
--- @class KiroMigrate
local M = {}

--- Migration rules for config changes
--- @type table<string, {from: string, to: string, transform?: function}>
local migrations = {
	-- Example: If we rename a config option in the future
	-- ["old_option_name"] = {
	--   from = "old_option_name",
	--   to = "new_option_name",
	--   transform = function(value) return value end
	-- }
}

--- Check if config uses deprecated options
--- @param config table Configuration to check
--- @return table warnings List of deprecation warnings
function M.check_deprecated(config)
	local warnings = {}
	
	for old_key, migration in pairs(migrations) do
		if config[old_key] ~= nil then
			table.insert(warnings, {
				old = migration.from,
				new = migration.to,
				message = string.format(
					"Config option '%s' is deprecated, use '%s' instead",
					migration.from,
					migration.to
				),
			})
		end
	end
	
	return warnings
end

--- Migrate old config to new format
--- @param config table Configuration to migrate
--- @return table migrated Migrated configuration
--- @return table changes List of changes made
function M.migrate(config)
	local migrated = vim.deepcopy(config)
	local changes = {}
	
	for old_key, migration in pairs(migrations) do
		if migrated[old_key] ~= nil then
			local old_value = migrated[old_key]
			local new_value = migration.transform and migration.transform(old_value) or old_value
			
			migrated[migration.to] = new_value
			migrated[old_key] = nil
			
			table.insert(changes, {
				from = migration.from,
				to = migration.to,
				old_value = old_value,
				new_value = new_value,
			})
		end
	end
	
	return migrated, changes
end

--- Generate migration report
--- @param config table Configuration to analyze
--- @return string report Human-readable migration report
function M.report(config)
	local warnings = M.check_deprecated(config)
	
	if #warnings == 0 then
		return "✓ Configuration is up to date"
	end
	
	local lines = { "Configuration Migration Needed:", "" }
	
	for _, warning in ipairs(warnings) do
		table.insert(lines, string.format("  • %s", warning.message))
	end
	
	table.insert(lines, "")
	table.insert(lines, "Run :lua require('kiro.migrate').auto_migrate() to update")
	
	return table.concat(lines, "\n")
end

--- Automatically migrate configuration file
--- @param config_path string|nil Path to config file (default: init.lua location)
--- @return boolean success True if migration succeeded
--- @return string|nil error Error message if failed
function M.auto_migrate(config_path)
	-- This is a placeholder for future migrations
	-- When we have actual migrations, this will read the config file,
	-- apply migrations, and write back
	return true, nil
end

--- Validate config against current schema
--- @param config table Configuration to validate
--- @return boolean valid True if valid
--- @return table issues List of validation issues
function M.validate_schema(config)
	local issues = {}
	local Config = require("kiro.config")
	
	-- Check for unknown options
	local known_options = vim.tbl_keys(Config.defaults)
	for key, _ in pairs(config) do
		if not vim.tbl_contains(known_options, key) then
			table.insert(issues, {
				type = "unknown_option",
				key = key,
				message = string.format("Unknown config option: '%s'", key),
				suggestion = "Check documentation for valid options",
			})
		end
	end
	
	return #issues == 0, issues
end

--- Show migration help
--- @return string help Help text for migrations
function M.help()
	return [[
Kiro Configuration Migration

Commands:
  :lua require('kiro.migrate').report(config)        - Check for deprecated options
  :lua require('kiro.migrate').migrate(config)       - Migrate configuration
  :lua require('kiro.migrate').validate_schema(config) - Validate against schema

Example:
  local config = { split = 'vsplit', debug = true }
  local warnings = require('kiro.migrate').check_deprecated(config)
  if #warnings > 0 then
    print(require('kiro.migrate').report(config))
  end
]]
end

return M

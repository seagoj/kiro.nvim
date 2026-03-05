--- Module dependency analyzer
--- @class KiroDeps
local M = {}

--- Get module dependencies
--- @return table dependencies Map of module to its dependencies
function M.analyze()
	return {
		["kiro.init"] = {
			always = { "kiro.config", "kiro.logger", "kiro.constants", "kiro.state" },
			lazy = {
				"kiro.terminal",
				"kiro.commands",
				"kiro.lsp",
				"kiro.validate",
				"kiro.terminal.window",
				"kiro.migrate",
			},
		},
		["kiro.config"] = {
			always = { "kiro.constants", "kiro.error" },
			lazy = { "kiro.validate" },
		},
		["kiro.commands"] = {
			always = { "kiro.constants", "kiro.logger", "kiro.error" },
			lazy = {},
		},
		["kiro.terminal"] = {
			always = {
				"kiro.terminal.shell",
				"kiro.terminal.window",
				"kiro.logger",
				"kiro.constants",
				"kiro.error",
			},
			lazy = { "kiro.terminal.toggleterm" },
		},
		["kiro.terminal.window"] = {
			always = { "kiro.terminal.shell", "kiro.logger", "kiro.constants", "kiro.error" },
			lazy = {},
		},
		["kiro.terminal.toggleterm"] = {
			always = { "kiro.terminal.shell", "kiro.logger", "kiro.constants", "kiro.error" },
			lazy = {},
		},
		["kiro.terminal.shell"] = {
			always = { "kiro.constants" },
			lazy = {},
		},
		["kiro.lsp"] = {
			always = { "kiro.logger" },
			lazy = {},
		},
		["kiro.logger"] = {
			always = { "kiro.constants" },
			lazy = {},
		},
		["kiro.validate"] = {
			always = {},
			lazy = {},
		},
		["kiro.error"] = {
			always = {},
			lazy = {},
		},
		["kiro.constants"] = {
			always = {},
			lazy = {},
		},
		["kiro.state"] = {
			always = {},
			lazy = {},
		},
		["kiro.migrate"] = {
			always = {},
			lazy = { "kiro.config" },
		},
	}
end

--- Check for circular dependencies
--- @return boolean has_circular True if circular dependencies found
--- @return table|nil cycles List of circular dependency chains
function M.check_circular()
	local deps = M.analyze()
	local visited = {}
	local stack = {}
	local cycles = {}

	local function visit(module, path)
		if stack[module] then
			-- Found a cycle
			local cycle = {}
			local in_cycle = false
			for _, m in ipairs(path) do
				if m == module then
					in_cycle = true
				end
				if in_cycle then
					table.insert(cycle, m)
				end
			end
			table.insert(cycle, module)
			table.insert(cycles, cycle)
			return
		end

		if visited[module] then
			return
		end

		visited[module] = true
		stack[module] = true
		table.insert(path, module)

		local module_deps = deps[module]
		if module_deps then
			for _, dep in ipairs(module_deps.always or {}) do
				visit(dep, vim.deepcopy(path))
			end
		end

		stack[module] = nil
	end

	for module, _ in pairs(deps) do
		visit(module, {})
	end

	return #cycles > 0, #cycles > 0 and cycles or nil
end

--- Generate dependency graph in DOT format
--- @return string dot DOT format graph
function M.to_dot()
	local deps = M.analyze()
	local lines = {
		"digraph KiroDependencies {",
		'  rankdir=LR;',
		'  node [shape=box];',
		"",
	}

	-- Add nodes with colors
	table.insert(lines, "  // Core modules")
	for _, module in ipairs({ "kiro.constants", "kiro.logger", "kiro.state", "kiro.error" }) do
		table.insert(lines, string.format('  "%s" [fillcolor=lightblue, style=filled];', module))
	end

	table.insert(lines, "")
	table.insert(lines, "  // Main module")
	table.insert(lines, '  "kiro.init" [fillcolor=lightgreen, style=filled];')

	table.insert(lines, "")
	table.insert(lines, "  // Dependencies")
	for module, module_deps in pairs(deps) do
		for _, dep in ipairs(module_deps.always or {}) do
			table.insert(lines, string.format('  "%s" -> "%s";', module, dep))
		end
		for _, dep in ipairs(module_deps.lazy or {}) do
			table.insert(lines, string.format('  "%s" -> "%s" [style=dashed, color=gray];', module, dep))
		end
	end

	table.insert(lines, "}")
	return table.concat(lines, "\n")
end

--- Print dependency report
function M.report()
	local deps = M.analyze()
	local has_circular, cycles = M.check_circular()

	print("Kiro Module Dependencies")
	print(string.rep("=", 50))
	print("")

	if has_circular then
		print("⚠️  CIRCULAR DEPENDENCIES FOUND:")
		for i, cycle in ipairs(cycles) do
			print(string.format("  %d. %s", i, table.concat(cycle, " -> ")))
		end
		print("")
	else
		print("✓ No circular dependencies")
		print("")
	end

	print("Module Dependency Count:")
	for module, module_deps in pairs(deps) do
		local always_count = #(module_deps.always or {})
		local lazy_count = #(module_deps.lazy or {})
		local total = always_count + lazy_count
		print(string.format("  %-30s %2d (%d always, %d lazy)", module, total, always_count, lazy_count))
	end

	print("")
	print("Legend:")
	print("  always = loaded immediately")
	print("  lazy   = loaded on demand")
end

return M

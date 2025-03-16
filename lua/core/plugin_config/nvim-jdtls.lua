vim.notify("Using nvim-jdtls for java", vim.log.levels.INFO)
-- 🔍 Validate Java Home
local java_home = vim.fn.expand("$JAVA_HOME")
if not vim.fn.isdirectory(java_home) then
	-- vim.notify("❌ JAVA_HOME is not set correctly: " .. java_home)
	return
end
local java_executable = java_home .. "/bin/java"

-- vim.notify("java executable = " .. java_executable .. "\n", vim.log.levels.INFO)

-- Define the base JDTLS directory as a variable
local jdtls_home = vim.fn.expand("$HOME/.local/share/eclipse.jdt.ls")

local general_utils = _G.general_utils_franck
if not general_utils then
	-- vim.notify("❌ Error: `_G.general_utils_franck` not found!")
	return
end

local project_root = general_utils.find_project_root()

if not project_root then
	-- vim.notify("⚠️(java): Could not determine project root, using current working directory.")
	project_root = vim.fn.getcwd()
end
-- vim.notify("🔍 JDTLS root_dir: " .. project_root, vim.log.levels.INFO)

-- Extract project name from project root
local project_name = vim.fn.fnamemodify(project_root, ":t")
--vim.notify("(java) ✅ Project Name: " .. project_name .. "\n", vim.log.levels.INFO)

-- Ensure workspace directory is valid
local workspace_dir = vim.fn.expand("$HOME/.cache/jdtls/workspace/") .. "/" .. project_name

-- Ensure workspace directory exists
if not vim.fn.isdirectory(workspace_dir) then
	vim.fn.mkdir(workspace_dir, "p")
	-- vim.notify("📂 Created workspace directory: " .. workspace_dir, vim.log.levels.INFO)
end

local jdtls = require("jdtls")

-- Use the jdtls_home variable to find the JDTLS launcher
local jdtls_launcher = vim.fn.glob(jdtls_home .. "/plugins/org.eclipse.equinox.launcher_*.jar")
if jdtls_launcher == "" or not vim.fn.filereadable(jdtls_launcher) then
	-- vim.notify("❌ JDTLS Launcher not found or is not readable!")
	return
end
-- vim.notify("JDTLS Launcher path: " .. jdtls_launcher, vim.log.levels.INFO)

local status, debug_plugin = pcall(function()
  local path = vim.fn.glob("$HOME/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar", true, true)
  if path == "" then
    error("No Java Debug plugin found!")
  end
  return path
end)

if not status then
  vim.notify("Error loading Java Debug plugin: " .. debug_plugin, vim.log.levels.ERROR)
else
  print("Using Debug Plugin:", debug_plugin)
end

-- Use the jdtls_home variable to find the JDTLS configuration path
local jdtls_config_path = jdtls_home .. "/config_linux"
if not vim.fn.isdirectory(jdtls_config_path) then
	-- vim.notify("❌ JDTLS configuration directory not found: " .. jdtls_config_path)
	return
end

-- ✅ Ensure Java 21+ Modules Path
local java_modules = java_home .. "/jmods"
if not vim.fn.filereadable(java_modules) then
	-- vim.notify("❌ Java modules not found in: " .. java_modules)
	return
end

-- vim.notify("java_modules: " .. java_modules, vim.log.levels.INFO)

local classpath = project_root .. "/.classpath"

-- vim.notify("classpath: " .. classpath, vim.log.levels.INFO)
local hardCmd = {
	java_executable,
	"-XX:+IgnoreUnrecognizedVMOptions",
	"-XX:+IgnoreUnrecognizedVMOptions",
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
	"-Dlog.protocol=true",
	"-Dlog.level=ALL",
	"-Xmx1G",

	"--module-path",
	java_modules,
	"--add-modules=ALL-SYSTEM",
	"--add-opens",
	"java.base/java.util=ALL-UNNAMED",
	"--add-opens",
	"java.base/java.lang=ALL-UNNAMED",
	"-jar",
	jdtls_launcher, -- Use validated launcher path
	"-configuration",
	jdtls_config_path, -- ✅ Ensure this is correct
	"-data",
	workspace_dir,
	"cp", -- optional
	classpath, --optional
} -- ✅ Ensure workspace is in $HOME/.cache

local jdtls_path = vim.fn.expand(jdtls_home .. "/bin/jdtls")
local simpleCmd = {
	jdtls_path,
	"-configuration",
	jdtls_config_path,
	"-data",
	workspace_dir,
}

-- ✅ Correcting -configuration and -data paths
local config = {
	cmd = hardCmd,

	root_dir = project_root, -- Use detected project root (or fallback to CWD)

	settings = {
		java = {
			configuration = {
				runtimes = {
					{ name = "JavaSE-21", path = java_home },
				},
			},
		},
	},

	init_options = {
--		bundles = { debug_plugin }, -- Use validated debug plugin path
	},
}

-- vim.notify("🚀 Starting JDTLS for " .. project_name, vim.log.levels.INFO)

jdtls.start_or_attach(config)

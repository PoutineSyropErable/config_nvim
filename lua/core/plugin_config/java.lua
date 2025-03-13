local project_root = _G.general_utils_franck.find_project_root()

if not project_root then
	print("⚠️ Could not determine project root, using current working directory.")
	project_root = vim.fn.getcwd()
end

-- Extract project name from project root
local project_name = vim.fn.fnamemodify(project_root, ":t")
print("✅ Project Name:", project_name)

-- Ensure workspace directory is valid
local workspace_dir = vim.fn.expand("$HOME/.cache/jdtls/workspace/") .. "/" .. project_name

local jdtls = require("jdtls")

-- Ensure JDTLS launcher exists
local jdtls_launcher = vim.fn.glob("$HOME/.local/share/eclipse.jdt.ls/plugins/org.eclipse.equinox.launcher_*.jar")
if jdtls_launcher == "" then
	print("❌ JDTLS Launcher not found!")
	return
end

-- Ensure debug plugin exists
local debug_plugin = vim.fn.glob("$HOME/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")
if debug_plugin == "" then
	print("❌ Java Debug Plugin not found!")
	return
end

-- Ensure JDTLS configuration path is correct
local jdtls_config_path = vim.fn.expand("$HOME/.local/share/eclipse.jdt.ls/config_linux")
if not vim.fn.isdirectory(jdtls_config_path) then
	print("❌ JDTLS configuration directory not found: " .. jdtls_config_path)
	return
end

-- ✅ Correcting -configuration and -data paths
local config = {
	cmd = {
		"java",
		"-XX:+IgnoreUnrecognizedVMOptions",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1G",
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
		workspace_dir, -- ✅ Ensure workspace is in $HOME/.cache
	},

	root_dir = project_root, -- Use detected project root (or fallback to CWD)

	settings = {
		java = {
			configuration = {
				runtimes = {
					{ name = "JavaSE-17", path = "/home/francois/.local/java/java-17-openjdk" },
				},
			},
		},
	},

	init_options = {
		bundles = { debug_plugin }, -- Use validated debug plugin path
	},
}

jdtls.start_or_attach(config)

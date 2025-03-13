local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.expand("$HOME/.cache/jdtls/workspace/") .. project_name

local jdtls = require("jdtls")

local config = {
	cmd = {
		"java", -- Ensure Java 21+ is installed
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
		vim.fn.glob("~/.local/share/eclipse.jdt.ls/plugins/org.eclipse.equinox.launcher_*.jar"),
		"-configuration",
		"~/.local/share/eclipse.jdt.ls/config_linux",
		"-data",
		workspace_dir,
	},

	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),

	settings = {
		java = {
			configuration = {
				runtimes = {
					{ name = "JavaSE-17", path = "/home/francois/.local/java/java-17-openjdk/" },
				},
			},
		},
	},

	init_options = {
		bundles = { vim.fn.expand("$HOME/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin.jar") },
	},
}

-- local bundles = {
-- 	vim.fn.glob("~/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin.jar", true),
-- }
--
-- config.init_options.bundles = bundles
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function() require("jdtls").start_or_attach(config) end,
})

local lspconfig = require("lspconfig")
local lsp_defaults = lspconfig.util.default_config
_G.MyRootDir = nil -- Global variable to hold the root directory

lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())
--------------------------------------- JAVA  ---------------------------------------
local javafx_path = "/usr/lib/jvm/javafx-sdk-17.0.13/lib"

-- Add each JavaFX JAR file
local javafx_libs = {
	javafx_path .. "/javafx.base.jar",
	javafx_path .. "/javafx.controls.jar",
	javafx_path .. "/javafx.fxml.jar",
	javafx_path .. "/javafx.graphics.jar",
	javafx_path .. "/javafx.media.jar",
	javafx_path .. "/javafx.swing.jar",
	javafx_path .. "/javafx.web.jar",
}

lspconfig.jdtls.setup({
	cmd = { "jdtls" },
	root_dir = lspconfig.util.root_pattern(".git", "pom.xml", "build.gradle", ".classpath"),
	settings = {
		java = {
			configuration = {
				runtimes = {
					{ name = "JavaSE-23", path = "/usr/lib/jvm/java-23-openjdk" },
					-- { name = "JavaFX-23", path = "/usr/lib/jvm/javafx-sdk-23.0.1/lib" },
					{ name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk" },
					-- { name = "JavaFX-17", path = "/usr/lib/jvm/javafx-sdk-17.0.13/lib" },
				},
			},
		},
	},
	capabilities = lsp_defaults.capabilities,
	on_attach = function(client, bufnr)
		-- Update the global variable when the LSP attaches
		_G.MyRootDir = client.config.root_dir
		-- print("Java root directory detected: " .. (_G.MyRootDir or "none"))
	end,
})

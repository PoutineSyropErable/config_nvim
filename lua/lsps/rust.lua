-- lua/core/lsps/rust.lua
M = {}

M.config = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" }, -- Apply to Rust files
	root_dir = require("lspconfig.util").root_pattern("Cargo.toml", "rust-project.json", ".git"), -- Detect project root
	settings = {
		["rust-analyzer"] = {
			assist = {
				importGranularity = "module",
				importPrefix = "by_self",
			},
			cargo = {
				loadOutDirsFromCheck = true,
				allFeatures = true,
			},
			procMacro = {
				enable = true, -- Enable procedural macros
			},
			check = {
				command = "clippy", -- Use Clippy for on-save linting
			},
		},
	},

	on_attach = function(client, bufnr)
		-- your on_attach logic
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("lua lsp attached")
		lsp_helper.add_keybinds()
	end,
}

return M

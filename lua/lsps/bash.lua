-- lua/core/lsps/bash.lua
M = {}

M.config = {
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash", "zsh" },
	root_dir = require("lspconfig.util").root_pattern(".git", vim.fn.getcwd()),
	settings = {
		bash = {
			useLinting = true,
		},
	},
	on_attach = function(client, bufnr)
		-- your on_attach logic
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("bash lsp attached")
		lsp_helper.add_keybinds()
	end,
}

return M

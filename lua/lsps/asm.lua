if false then
	local lspconfig = {}
	lspconfig.asm_lsp.setup({
		cmd = { "asm-lsp" },
		filetypes = { "asm", "s", "S" },
		root_dir = lspconfig.util.root_pattern(".git", ".asm-lsp.toml"),
	})
end

local M = {}

M.config = {
	cmd = { "asm-lsp" },
	filetypes = { "asm", "s", "S" },
	root_dir = require("lspconfig.util").root_pattern(".git", ".asm-lsp.toml"),
	on_attach = function(client, bufnr)
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("c lsp attached")
		lsp_helper.add_keybinds()
	end,
}

return M

-- lua/core/lsps/latex.lua
M = {}

local tex_output = os.getenv("HOME") .. "/.texfiles/" -- Directory for auxiliary files
local pdf_output_dir = vim.fn.expand("%:p:h") -- Directory where the PDF should be saved
local tex_file = vim.fn.expand("%:p") -- Full path to the LaTeX file
local pdf_file = pdf_output_dir .. "/" .. vim.fn.expand("%:t:r") .. ".pdf" -- PDF filename based on the LaTeX file

M.config = {
	cmd = { "texlab" },
	filetypes = { "tex", "bib", "plaintex", "latex" },
	root_dir = require("lspconfig.util").root_pattern(".git", ".latexmkrc", "main.tex"),
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = {
					"-pdf",
					"-interaction=nonstopmode",
					"-synctex=1",
					"-aux-directory=" .. tex_output,
					"-output-directory=" .. pdf_output_dir,
					tex_file,
				},
				onSave = false, -- Compile on save
				forwardSearchAfter = true,
			},
			forwardSearch = {
				executable = "zathura",
				args = { "--synctex-forward", "%l:1:%f", pdf_file }, -- Ensure correct PDF file is opened
			},
			chktex = {
				onOpenAndSave = true, -- Lint on file open and save
				onEdit = true,
			},
			latexindent = {
				modifyLineBreaks = true,
			},
		},
	},

	on_attach = function(client, bufnr)
		-- your on_attach logic
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("latex lsp attached")
		lsp_helper.add_keybinds()
	end,
}

return M

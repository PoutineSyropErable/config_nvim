require("mason-lspconfig").setup({
	-- ensure_installed = { "lua_ls", "solargraph", "ts_ls", "pyright", "clangd", "jdtls" },
	ensure_installed = { "lua_ls", "solargraph", "ts_ls", "pyright", "clangd", "rust_analyzer", "texlab" },
})

require("mason-tool-installer").setup({

	ensure_installed = {
		"black",
		"debugpy",
		"flake8",
		"isort",
		"mypy",
		"pylint",
		"ruff",

		"prettier",
		"clangd",
		"clang-format",
		-- "clang-tidy",

		"texlab", -- lsp parser

		-- "chktex", -- Linter for LaTeX
		-- Get chktex by compiling it, figure it out lol.
		-- (http://git.savannah.nongnu.org/cgit/chktex.git)
		-- download, extract, cd
		-- /autogen.sh
		--./configure --prefix=/usr/local^J
		--make -j$(nproc)^J
		--sudo make install^J
		--echo 'export CHKTEXRC=/usr/local/etc/chktexrc' >> ~/.bashrc
		--echo 'export CHKTEXRC=/usr/local/etc/chktexrc' >> ~/.zshrc
		-- chatgpt to I.T./Debug/Make it work

		"latexindent", -- Formatter for LaTeX
	},
})

local lspconfig = require("lspconfig")
local lsp_defaults = lspconfig.util.default_config
_G.MyRootDir = nil -- Global variable to hold the root directory

lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

--------------------------------------- BASH ---------------------------------------

lspconfig.bashls.setup({
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash", "zsh" },
	root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
	settings = {
		bash = {
			useLinting = true,
		},
	},
})

--------------------------------------- LUA ---------------------------------------
lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			telemetry = { enable = false }, -- Disable telemetry
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})

--------------------------------------- PYTHON ---------------------------------------
lspconfig.pyright.setup({

	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic", -- Can be "off", "basic", or "strict"
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})

vim.api.nvim_create_user_command("PyrightDebug", function()
	-- Show LSP info
	vim.cmd("LspInfo")

	-- Print the detected root directory
	local clients = vim.lsp.get_active_clients()
	for _, client in ipairs(clients) do
		if client.name == "pyright" then
			print("🛠 Pyright Root: " .. (client.config.root_dir or "Unknown"))
		end
	end

	-- Run Pyright manually
	vim.cmd("!pyright --verbose")
end, {})

--------------------------------------- C/C++ ---------------------------------------

lspconfig.clangd.setup({
	cmd = {
		-- clangd command with additional options
		"clangd",
		"--offset-encoding=utf-16",
		"--background-index", -- Enable background indexing
		"--clang-tidy", -- Enable clang-tidy diagnostics
		"--completion-style=bundled", -- Style for autocompletion
		"--cross-file-rename", -- Support for renaming symbols across files
		"--header-insertion=iwyu", -- Include "what you use" insertion
		"--log=verbose",
	},
	capabilities = lsp_defaults.capabilities, -- Auto-completion capabilities
	filetypes = { "c", "cpp", "objc", "objcpp", "x" },
	root_dir = lspconfig.util.root_pattern("compile_commands.json", ".clang-format", ".clangd", "compile_flags.txt", "Makefile", "build.sh", ".git"),
	settings = {
		clangd = {
			fallbackFlags = { "-std=c++17" }, -- Adjust this if using a different C++ standard
		},
	},
	on_attach = function(client, bufnr)
		local root = client.config.root_dir
		_G.MyRootDir = client.config.root_dir
		-- print("Clangd root directory detected: " .. (root or "none"))
	end,
})

--------------------------------------- RUST ---------------------------------------
lspconfig.rust_analyzer.setup({
	cmd = { "rust-analyzer" },
	capabilities = lsp_defaults.capabilities, -- Enable LSP capabilities
	filetypes = { "rust" }, -- Apply to Rust files
	root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json", ".git"), -- Detect project root
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
		-- Keymaps specific to Rust LSP
		_G.MyRootDir = client.config.root_dir
		local opts = { buffer = bufnr }
		-- vim.keymap.set("n", "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
		-- vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
		-- vim.keymap.set("n", "<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
	end,
})

------------------------------------------------ End of LANGUAGE Config ----------------------------------------

lspconfig.solargraph.setup({})
lspconfig.ts_ls.setup({})
lspconfig.gopls.setup({})
lspconfig.tailwindcss.setup({})

-- Hyprlang LSP
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.hl", "hypr*.conf" },
	callback = function(event)
		-- print(string.format("starting hyprls for %s", vim.inspect(event)))
		vim.lsp.start({
			name = "hyprlang",
			cmd = { "hyprls" },
			root_dir = vim.fn.getcwd(),
		})
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		-- Properly shut down LSP servers when exiting Neovim
		for _, client in pairs(vim.lsp.get_active_clients()) do
			client.stop()
		end
	end,
})

------------------------------------------------ LATEX AND TEXLIVE ------------------------------------------------

local tex_output = os.getenv("HOME") .. "/.texfiles/" -- Directory for auxiliary files
local pdf_output_dir = vim.fn.expand("%:p:h") -- Directory where the PDF should be saved
local tex_file = vim.fn.expand("%:p") -- Full path to the LaTeX file
local pdf_file = pdf_output_dir .. "/" .. vim.fn.expand("%:t:r") .. ".pdf" -- PDF filename based on the LaTeX file

lspconfig.texlab.setup({
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
	capabilities = lsp_defaults.capabilities,
	on_attach = function(client, bufnr)
		print("LaTeX File:", tex_file)
		print("Aux Directory:", tex_output)
		print("PDF Output Directory:", pdf_output_dir)
		print("PDF File:", pdf_file)
		print(
			"Compile Command: latexmk -pdf -interaction=nonstopmode -synctex=1 -aux-directory="
				.. tex_output
				.. " -output-directory="
				.. pdf_output_dir
				.. " "
				.. tex_file
		)
		print("View Command: zathura --synctex-forward %l:1:%f " .. pdf_file)
	end,
})

vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_view_forward_search_on_start = false
vim.g.vimtex_view_general_viewer = "zathura"
vim.g.vimtex_view_general_options = "--synctex-forward @line:1:@tex"

vim.g.vimtex_compiler_latexmk = {
	aux_dir = tex_output, -- Auxiliary files directory
	out_dir = pdf_output_dir, -- Output directory
	callback = false,
	continuous = false, -- Enable continuous compilation
	background = false,
}

-- vim.api.nvim_create_user_command("CheckLSP", function()
-- 	local clients = vim.lsp.get_active_clients({ bufnr = 0 })
-- 	if #clients > 1 then
-- 		print("🚀 More than one LSP server is attached to this buffer:")
-- 		for _, client in ipairs(clients) do
-- 			print(" - " .. client.name)
-- 		end
-- 	elseif #clients == 1 then
-- 		print("✅ Only one LSP server is attached: " .. clients[1].name)
-- 	else
-- 		print("❌ No LSP servers attached to this buffer")
-- 	end
-- end, {})

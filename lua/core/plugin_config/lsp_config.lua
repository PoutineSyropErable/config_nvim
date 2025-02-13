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

lspconfig.bashls.setup({
	cmd = { "bash-language-server", "start" },
	filetypes = { "sh", "bash" },
	root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
	settings = {
		bash = {
			useLinting = true,
		},
	},
})

lspconfig.lua_ls.setup({
	settings = {
		Lua = {
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

require("lspconfig").solargraph.setup({})
require("lspconfig").ts_ls.setup({})
require("lspconfig").gopls.setup({})
require("lspconfig").tailwindcss.setup({})

local tex_file = "%f" -- LaTeX source file
local pdf_file = "%p" -- PDF in the same directory as the tex file
local tex_output = os.getenv("HOME") .. "/.texfiles/"

lspconfig.texlab.setup({
	cmd = { "texlab" },
	filetypes = { "tex", "bib", "plaintex", "latex" },
	root_dir = lspconfig.util.root_pattern(".git", ".latexmkrc", "main.tex"),
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = {
					"-pdf",
					"-interaction=nonstopmode",
					"-synctex=1",
					"-auxdir=" .. tex_output, -- Store aux files in ~/.texfiles/
					"-outdir=" .. tex_output, -- Store temp files in ~/.texfiles/
					"%f", -- Compile current file
				},
				onSave = true, -- Compile on save
				forwardSearchAfter = true,
			},
			forwardSearch = {
				executable = "zathura",
				args = { "--synctex-forward", "%l:1:%f", "%p" }, -- PDF remains in source folder
			},
			chktex = {
				onOpenAndSave = true,
				onEdit = true,
			},
			latexindent = {
				modifyLineBreaks = true,
			},
		},
	},
	capabilities = lsp_defaults.capabilities,
	on_attach = function(client, bufnr)
		_G.MyRootDir = client.config.root_dir
		local tex_file = vim.api.nvim_buf_get_name(bufnr) -- Get current file name
		local pdf_file = tex_file:gsub("%.tex$", ".pdf") -- Compute expected PDF path

		print("LaTeX File: " .. tex_file)
		print("Auxiliary Output Directory: " .. tex_output)
		print("PDF File: " .. pdf_file)
		print(
			"Compile Command: latexmk -pdf -interaction=nonstopmode -synctex=1 -auxdir=" .. tex_output .. " -outdir=" .. tex_output .. " " .. tex_file
		)
		print("View Command: zathura --synctex-forward %l:1:%f " .. pdf_file)
	end,
})

vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_view_forward_search_on_start = false
vim.g.vimtex_compiler_latexmk = {
	aux_dir = tex_output, -- Move auxiliary files to ~/.texfiles/
	out_dir = tex_output, -- Store build artifacts in ~/.texfiles/
	callback = 1,
	continuous = false, -- Disable VimTeX auto-compilation
	background = false,
}

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

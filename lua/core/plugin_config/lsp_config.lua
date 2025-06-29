require("mason").setup()

require("mason-tool-installer").setup({
	ensure_installed = {
		"black", -- Python Formatter
		"isort", -- Import sorter
		"pylint", -- Python Linter (keep this)
		"debugpy", -- Python Debugger

		"clang-format", -- C auto formatter

		"texlab", -- Latex LSP
		"latexindent", -- LaTex autoformatter

		"prettier", -- json and other web
	},
})

require("lint").linters_by_ft = {
	python = { "pylint" }, -- Primary linter
	c = { "clangtidy" },
	cpp = { "clangtidy" },
}

require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "solargraph", "ts_ls", "pyright", "clangd", "jdtls" },
	-- ensure_installed = { "lua_ls", "solargraph", "ts_ls", "pyright", "clangd", "rust_analyzer", "texlab" },
	automatic_installation = true,
	automatic_enable = false,
})

local lspconfig = require("lspconfig")
local lsp_defaults = lspconfig.util.default_config
lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

-- Run pylint on save
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function() require("lint").try_lint() end,
})

-- vim.diagnostic.config({
-- 	virtual_text = {
-- 		spacing = 4,
-- 		prefix = "■", -- or "■", or "" for no symbol
-- 	},
-- 	signs = true,
-- 	underline = true,
-- 	update_in_insert = false,
-- 	severity_sort = true,
-- })

_G.MyRootDir = nil -- Global variable to hold the root directory

-- "chktex" installation guide -- Linter for LaTeX
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

---------------------------------------- ASM -------------------------------------
lspconfig.asm_lsp.setup({
	cmd = { "asm-lsp" },
	filetypes = { "asm", "s", "S" },
	root_dir = lspconfig.util.root_pattern(".git", ".asm-lsp.toml"),
})

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
-- Use lazydev
if false then
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

		on_attach = function(client, bufnr)
			-- This function will be called when the LSP is fully initialized
			general_utils_franck.send_notification("please work")
			_G.print_custom("LSP " .. client.name .. " is attached!")
			_G.print_custom("LSP " .. client.name .. vim.inspect(client.initialized))
			-- You can perform additional actions here, for example, setting some custom configurations
		end,
	})
end
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
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		if client.name == "pyright" then
			_G.print_custom("🛠 Pyright Root: " .. (client.config.root_dir or "Unknown"))
		end
	end

	-- Run Pyright manually
	vim.cmd("!pyright --verbose")
end, {})

------------------------------------------ Open CL -----------------------------
lspconfig.opencl_ls.setup({
	cmd = { "opencl-language-server" },
	filetypes = { "opencl" },
	root_dir = lspconfig.util.root_pattern(".git", ".asm-lsp.toml"),
	capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities, {
		offsetEncoding = "utf-8",
		positionEncodings = "utf-8",
	}),
	init_options = {
		offsetEncoding = "utf-8", -- Some servers need this too
	},
})

-- Not needed, or else it would add two clients

--------------------------------------- C/C++ ---------------------------------------

lspconfig.clangd.setup({
	cmd = {
		-- clangd command with additional options
		"clangd",
		"--offset-encoding=utf-8",
		"--background-index", -- Enable background indexing
		"--clang-tidy", -- Enable clang-tidy diagnostics
		"--completion-style=bundled", -- Style for autocompletion
		"--cross-file-rename", -- Support for renaming symbols across files
		"--header-insertion=iwyu", -- Include "what you use" insertion
		"--log=verbose",
		"--query-driver=/opt/rocm/llvm/bin/*", -- Critical for ROCm OpenCL
	},
	init_options = {
		clangdFileStatus = true,
		fallbackFlags = {
			"-I/opt/rocm/opencl/include", -- ROCm OpenCL headers
			"-I/usr/include/clc", -- Generic OpenCL headers
			"-cl-std=CL2.0", -- OpenCL version flag
			"-xcl", -- Force OpenCL mode
		},
	},
	capabilities = lsp_defaults.capabilities, -- Auto-completion capabilities
	filetypes = { "c", "cpp", "objc", "objcpp", "x", "opencl" },
	root_dir = lspconfig.util.root_pattern("compile_commands.json", ".clang-format", ".clangd", "compile_flags.txt", "Makefile", "build.sh", ".git"),
	settings = {
		clangd = {
			fallbackFlags = { "-std=c++17" }, -- Adjust this if using a different C++ standard
		},
	},
	on_attach = function(client, bufnr)
		local root = client.config.root_dir
		_G.MyRootDir = client.config.root_dir
		_G.print_custom("test")
		general_utils_franck.send_notification("test")
		-- _G.print_custom("Clangd root directory detected: " .. (root or "none"))
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
	end,
})

---------------------------------------------------- Start of Java ------------------------------------------
local useJavaLspConfig = PRE_CONFIG_FRANCK.useJavaLspConfig

if useJavaLspConfig then
	vim.notify("Using lsp config for java", vim.log.levels.INFO)
	local javafx_path = "/usr/lib/jvm/javafx-sdk-17.0.13/lib"

	local jdtls_home = vim.fn.expand("$HOME/.local/share/eclipse.jdt.ls")
	local jdtls_executable = vim.fn.expand(jdtls_home .. "/bin/jdtls")

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

	local get_debug_plugin = function()
		local home = os.getenv("HOME")
		local cmd = "ls -1 " .. home .. "/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar 2>/dev/null"

		local result = vim.fn.systemlist(cmd)

		-- Check if the command returned valid output
		if #result > 0 then
			return result[1] -- Return the first match
		else
			return nil -- No file found
		end
	end

	debug_plugin = get_debug_plugin()
	_G.print_custom("Java Debug Plugin Path:", debug_plugin)

	local general_utils = _G.general_utils_franck
	if not general_utils then
		vim.notify("❌ Error: `_G.general_utils_franck` not found!")
		return
	end
	local project_root = general_utils.find_project_root(true)

	if not project_root then
		vim.notify("⚠️(java): Could not determine project root, using current working directory.")
		project_root = vim.fn.getcwd()
	end
	vim.notify("🔍 JDTLS root_dir: " .. project_root, vim.log.levels.INFO)

	-- Extract project name from project root
	local project_name = vim.fn.fnamemodify(project_root, ":t")
	vim.notify("(java) ✅ Project Name: " .. project_name .. "\n", vim.log.levels.INFO)

	-- Ensure workspace directory is valid
	local workspace_dir = vim.fn.expand("$HOME/.cache/jdtls/workspace") .. "/" .. project_name

	lspconfig.jdtls.setup({
		cmd = { "jdtls", "-data", workspace_dir },
		-- cmd = { "jdtls" },
		root_dir = project_root,
		settings = {
			java = {
				configuration = {
					runtimes = {
						{ name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk", default = true },
						{ name = "JavaSE-23", path = "/usr/lib/jvm/java-23-openjdk" },
						{ name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk" },
					},
				},
			},
		},

		init_options = {
			--bundles = { debug_plugin }, -- Use validated debug plugin path
		},
		capabilities = lsp_defaults.capabilities,
		on_attach = function(client, bufnr)
			-- Update the global variable when the LSP attaches
			_G.MyRootDir = client.config.root_dir
			-- _G.print_custom("Java root directory detected: " .. (_G.MyRootDir or "none"))
		end,
	})
end

-- att the bundles back here

if PRE_CONFIG_FRANCK.useNvimJava and not PRE_CONFIG_FRANCK.useJavaLspConfig then
	require("lspconfig").jdtls.setup({})
end

------------------------------------------------ End of LANGUAGE Config ----------------------------------------

lspconfig.solargraph.setup({})
lspconfig.ts_ls.setup({})
lspconfig.gopls.setup({})
lspconfig.tailwindcss.setup({})

-- Hyprlang LSP
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.hl", "hypr*.conf" },
	callback = function(event)
		-- _G.print_custom(string.format("starting hyprls for %s", vim.inspect(event)))
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
		for _, client in pairs(vim.lsp.get_clients()) do
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
		_G.print_custom("LaTeX File:", tex_file)
		_G.print_custom("Aux Directory:", tex_output)
		_G.print_custom("PDF Output Directory:", pdf_output_dir)
		_G.print_custom("PDF File:", pdf_file)
		_G.print_custom(
			"Compile Command: latexmk -pdf -interaction=nonstopmode -synctex=1 -aux-directory="
				.. tex_output
				.. " -output-directory="
				.. pdf_output_dir
				.. " "
				.. tex_file
		)
		_G.print_custom("View Command: zathura --synctex-forward %l:1:%f " .. pdf_file)
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
-- 	 _G.print_custom("🚀 More than one LSP server is attached to this buffer:")
-- 		for _, client in ipairs(clients) do
-- 		 _G.print_custom(" - " .. client.name)
-- 		end
-- 	elseif #clients == 1 then
-- 	 _G.print_custom("✅ Only one LSP server is attached: " .. clients[1].name)
-- 	else
-- 	 _G.print_custom("❌ No LSP servers attached to this buffer")
-- 	end
-- end, {})

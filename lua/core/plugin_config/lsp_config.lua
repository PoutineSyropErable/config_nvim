require("mason-lspconfig").setup({
	-- ensure_installed = { "lua_ls", "solargraph", "ts_ls", "pyright", "clangd", "jdtls" },
	ensure_installed = { "lua_ls", "solargraph", "ts_ls", "pyright", "clangd", "rust_analyzer", "texlab" },
	automatic_installation = false,
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

local initialized_lsps = {} -- Cache LSPs per root directory

------------------------------------------- Helper functions ----------------------------

local function create_find_root_dir_function(patterns, fallback)
	local lsp_util = require("lspconfig.util")
	local root_dir_fn = lsp_util.root_pattern(unpack(patterns))

	-- Return a function that dynamically determines the root directory
	return function(fname)
		local root = root_dir_fn(fname)
		if not root and fallback then
			root = vim.fn.getcwd()
			print("⚠️ No root directory detected, falling back to CWD: " .. root)
		else
			print("✅ Root directory detected: " .. (root or "None"))
		end
		return root
	end
end
--------------------------------------- BASH ---------------------------------------

local bash_setup_dict = {}

local bash_pre_setup = function()
	bash_setup_dict = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh", "bash", "zsh" },
		root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
		settings = {
			bash = {
				useLinting = true,
			},
		},
	}
end
--------------------------------------- LUA ---------------------------------------
local lua_setup_dict = {}
local neodev_setup_dict = {}

local lua_pre_setup = function()
	print("Running lua pre setup (Inside the function)")
	require("neodev").setup({})

	-- Modify the existing global setup_dict instead of overwriting it
	lua_setup_dict.root_dir = create_find_root_dir_function({ ".git", ".luarc.json", ".luarc.jsonc" }, true)
	lua_setup_dict.on_attach = function(client, bufnr)
		print("✅ LSP " .. client.name .. " attached to buffer " .. bufnr)
		--
	end
	lua_setup_dict.filetypes = { "lua" }
	lua_setup_dict.settings = {
		Lua = {
			telemetry = { enable = false },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	}
end

--------------------------------------- PYTHON ---------------------------------------
local python_setup_dict = {}

local python_pre_setup = function()
	python_setup_dict = {
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic", -- Can be "off", "basic", or "strict"
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
				},
			},
		},
	}
end

local python_post_setup = function()
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
end
--------------------------------------- C/C++ ---------------------------------------
local clang_setup_dict = {}

local c_pre_setup = function()
	clang_setup_dict = {
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
		root_dir = lspconfig.util.root_pattern(
			"compile_commands.json",
			".clang-format",
			".clangd",
			"compile_flags.txt",
			"Makefile",
			"build.sh",
			".git"
		),
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
	}
end
--------------------------------------- RUST ---------------------------------------
local rust_setup_dict = {}
local rust_pre_setup = function()
	rust_setup_dict = {
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
	}
end

---------------------------------------------------- Start of Java ------------------------------------------
local useJavaLspConfig = PRE_CONFIG_FRANCK.useJavaLspConfig

local java_setup_dict = {}

local java_pre_setup = function()
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

		local debug_plugin = get_debug_plugin()
		print("Java Debug Plugin Path:", debug_plugin)

		local general_utils = _G.general_utils_franck
		if not general_utils then
			vim.notify("❌ Error: `_G.general_utils_franck` not found!")
			return
		end
		local project_root = general_utils.find_project_root()

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

		java_setup_dict = {
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
				-- print("Java root directory detected: " .. (_G.MyRootDir or "none"))
			end,
		}
	end

	-- att the bundles back here

	if PRE_CONFIG_FRANCK.useNvimJava and not PRE_CONFIG_FRANCK.useJavaLspConfig then
	end
end

------------------------------------------------ LATEX AND TEXLIVE ------------------------------------------------

local texlab_setup_dict = {}

local tex_output = nil
local pdf_output_dir = nil
local texlab_pre_setup = function()
	tex_output = os.getenv("HOME") .. "/.texfiles/" -- Directory for auxiliary files
	pdf_output_dir = vim.fn.expand("%:p:h") -- Directory where the PDF should be saved
	local tex_file = vim.fn.expand("%:p") -- Full path to the LaTeX file
	local pdf_file = pdf_output_dir .. "/" .. vim.fn.expand("%:t:r") .. ".pdf" -- PDF filename based on the LaTeX file

	texlab_setup_dict = {
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
	}
end

local texlab_post_setup = function()
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
end

------------------------------------------------ End of LANGUAGE Config ----------------------------------------

-------------------------------------- LAZY LOADING THE LSP ---------------------------------------

-- Store all LSP configs in a table for easy lookup
local lsp_configs = {
	bash = { name = "bashls", setup_dict = bash_setup_dict, pre_setup = bash_pre_setup },
	sh = { name = "bashls", setup_dict = bash_setup_dict, pre_setup = bash_pre_setup },
	zsh = { name = "bashls", setup_dict = bash_setup_dict, pre_setup = bash_pre_setup },
	lua = { name = "lua_ls", setup_dict = lua_setup_dict, pre_setup = lua_pre_setup },
	python = { name = "pyright", setup_dict = python_setup_dict, pre_setup = python_pre_setup, post_setup = python_post_setup },
	c = { name = "clangd", setup_dict = clang_setup_dict, pre_setup = c_pre_setup },
	cpp = { name = "clangd", setup_dict = clang_setup_dict, pre_setup = c_pre_setup },
	objc = { name = "clangd", setup_dict = clang_setup_dict, pre_setup = c_pre_setup },
	objcpp = { name = "clangd", setup_dict = clang_setup_dict, pre_setup = c_pre_setup },
	rust = { name = "rust_analyzer", setup_dict = rust_setup_dict, pre_setup = rust_pre_setup },
	java = { name = "jdtls", setup_dict = java_setup_dict, pre_setup = java_pre_setup },
	tex = { name = "texlab", setup_dict = texlab_setup_dict, pre_setup = texlab_pre_setup },
	latex = { name = "texlab", setup_dict = texlab_setup_dict, pre_setup = texlab_pre_setup },
	bib = { name = "texlab", setup_dict = texlab_setup_dict, pre_setup = texlab_pre_setup, post_setup = texlab_post_setup },
}

local additional_lsps = {
	ruby = { name = "solargraph", setup_dict = {} }, -- Solargraph for Ruby
	typescript = { name = "tsserver", setup_dict = {} }, -- TypeScript LSP
	javascript = { name = "tsserver", setup_dict = {} }, -- TypeScript LSP also handles JavaScript
	go = { name = "gopls", setup_dict = {} }, -- Go LSP
	html = { name = "tailwindcss", setup_dict = {} }, -- TailwindCSS LSP for HTML
	css = { name = "tailwindcss", setup_dict = {} }, -- TailwindCSS LSP for CSS files
}

-- Merge additional LSPs into `lsp_configs`
for ft, config in pairs(additional_lsps) do
	lsp_configs[ft] = config
end
----------------------------------------------------------------- LSP attach function ---------------------------------------
--- Ensures that the specified LSP is attached to the current buffer.
---
--- @param name string The name of the LSP server (e.g., "pyright", "clangd").
local function attach_lsp_to_buffer(name)
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_active_clients({ bufnr = bufnr })

	-- Check if the LSP client is already attached
	for _, client in ipairs(clients) do
		if client.name == name then
			print("ℹ️ LSP " .. name .. " is already attached to buffer " .. bufnr)
			return
		end
	end

	-- Try to find the initialized LSP and attach it
	for _, client in ipairs(vim.lsp.get_active_clients()) do
		if client.name == name then
			vim.lsp.buf_attach_client(bufnr, client.id)
			print("✅ LSP " .. name .. " attached to buffer " .. bufnr)
			return
		end
	end

	print("⚠️ LSP " .. name .. " not found to attach to buffer " .. bufnr)
end

---------------------------------------------------------------- Lazy setup --------------------------------------------------
--- Sets up an LSP server with optional pre- and post-setup hooks.
---
--- This function initializes an LSP server only if it hasn't been initialized
--- for the given root directory. It also ensures that necessary setup functions
--- are executed before and after setting up the LSP.
---
--- @param name string: The name of the LSP server (e.g., "pyright", "clangd").
--- @param setup_dict table: The LSP configuration dictionary that includes settings,
---                          commands, capabilities, and filetypes.
--- @param pre_setup function|nil: (Optional) A function that runs before setting up the LSP.
---                                Useful for additional configuration like setting global variables.
--- @param post_setup function|nil: (Optional) A function that runs after setting up the LSP.
---                                 Useful for defining user commands or further customization.

local function setup_lsp(name, setup_dict, pre_setup, post_setup)
	print("🔍 Setting up LSP: " .. name)

	-- Ensure setup_dict is valid
	if not setup_dict then
		print("⚠️ Error: LSP setup_dict is nil for " .. name)
		return
	end

	local bufname = vim.api.nvim_buf_get_name(0)

	-- If root_dir is missing, run pre_setup() to initialize it
	if not setup_dict.root_dir and pre_setup then
		print("⚠️ No root_dir detected, running pre_setup() for " .. name)
		pre_setup()
	end

	-- Compute root_dir if it's a function
	local root_dir = nil
	if setup_dict.root_dir then
		if type(setup_dict.root_dir) == "function" then
			root_dir = setup_dict.root_dir(bufname)
			print("🔄 root_dir function evaluated for " .. name .. ": " .. (root_dir or "nil"))
		else
			root_dir = setup_dict.root_dir
		end
	end

	-- Fallback to `getcwd()` if `root_dir` is still nil
	if not root_dir or root_dir == "" then
		print("⚠️ root_dir is still nil, falling back to CWD")
		root_dir = vim.fn.getcwd()
	end

	print("✅ Final root_dir for " .. name .. ": " .. root_dir)

	-- Prevent re-setup if already initialized
	initialized_lsps[name] = initialized_lsps[name] or {}
	if initialized_lsps[name][root_dir] then
		print("ℹ️ LSP " .. name .. " already initialized for " .. root_dir)

		-- ⚠️ Manually attach LSP to the buffer if setup already happened
		attach_lsp_to_buffer(name)
		return
	end

	-- Ensure `on_init` handles attachment
	setup_dict.on_init = function(client, _)
		print("🔄 LSP " .. name .. " is ready for attachment.")
		attach_lsp_to_buffer(name)

		-- Call post-setup AFTER attachment
		if post_setup then
			post_setup()
		end
	end

	-- Ensure `on_attach` is always set
	setup_dict.on_attach = function(client, bufnr)
		print("✅ LSP " .. name .. " attached to buffer " .. bufnr)
		if post_setup then
			post_setup()
		end
	end

	-- Debugging: Print full setup dictionary
	print("🔍 Setting up LSP: " .. name .. " with config: " .. vim.inspect(setup_dict))

	-- Setup the LSP
	lspconfig[name].setup(setup_dict)

	-- Mark LSP as initialized for this root
	initialized_lsps[name][root_dir] = true
end

----------------------------------------------------------------- Execute Lazy Setup -----------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(lsp_configs),
	callback = function(args)
		local filetype = args.match
		local lsp_info = lsp_configs[filetype]
		if lsp_info then
			-- Skip Java LSP if user disabled it
			if filetype == "java" and not PRE_CONFIG_FRANCK.useJavaLspConfig then
				return
			end

			setup_lsp(lsp_info.name, lsp_info.setup_dict, lsp_info.pre_setup, lsp_info.post_setup)
		end
	end,
})

-------------------------------------------------- HYPRLANG LSP --------------------------------------------------

-- Prevent multiple instances of Hyprlang LSP from starting
if not vim.g.hyprls_started then
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = { "*.hl", "hypr*.conf" },
		callback = function(event)
			if not vim.g.hyprls_started then
				vim.g.hyprls_started = true
				vim.lsp.start({
					name = "hyprlang",
					cmd = { "hyprls" },
					root_dir = vim.fn.getcwd(),
				})
			end
		end,
	})
end

------------------------------------------------ End of LANGUAGE Config ----------------------------------------
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		-- Properly shut down LSP servers when exiting Neovim
		for _, client in pairs(vim.lsp.get_active_clients()) do
			client.stop()
		end
	end,
})

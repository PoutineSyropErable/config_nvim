-- config/conform.lua

-- General formatter with tab settings
local function tab_formatter_general(command)
	return {
		command = command,
		args = { "--use-tabs", "--tab-width", "4" },
	}
end

-- C/C++ formatter with clang-format-specific arguments
local function tab_formatter_c(command)
	return {
		command = command,
		args = { "--style", "{UseTab: ForIndentation, IndentWidth: 4}" },
	}
end

-- Go formatter with gofumpt-specific arguments
local function tab_formatter_go()
	return {
		command = "gofumpt",
		args = { "-tabs", "-tabwidth=4" },
	}
end

uncrustify_args = {
	command = "uncrustify",
	stdin = false, -- Uncrustify does NOT support stdin
	args = { "-c", os.getenv("HOME") .. "/uncrustify.cfg", "--replace", "--no-backup", "$FILENAME" },
}

require("conform").setup({
	formatters = {
		black = {
			prepend_args = { "--line-length", "140" }, -- Set the line length for black
		},
		stylua = {
			prepend_args = {
				"--column-width",
				"151", -- Max width before breaking lines
				"--indent-type",
				"Tabs", -- Use tabs instead of spaces
				"--indent-width",
				"4", -- Set indentation width (tab width)
				"--collapse-simple-statement",
				"FunctionOnly", -- Collapse simple one-line statements
			},
		},
		prettier = {
			prepend_args = { "--tab-width", "4", "--use-tabs", "false" },
		},
		uncrustify = uncrustify_args,
	},
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		rust = { "rustfmt" },
		javascript = { "prettier", stop_after_first = true },
		javascriptreact = { "prettier", stop_after_first = true },
		typescript = { "prettier", stop_after_first = true },
		typescriptreact = { "prettier", stop_after_first = true },
		go = { "gofumpt", "golines", "goimports-reviser" },
		x = { "clang-format" },
		c = { "clang-format" }, -- ~/.clang-format contains the style
		-- c = { "uncrustify" },
		cpp = { "clang-format" },
		css = { "prettier" },
		haskell = { "ormolu" },
		yaml = { "yamlfmt" },
		-- templ = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		markdown = { "prettier" },
		gleam = { "gleam" },
		sql = { "sqlfmt" },
		asm = { "asmfmt" },
		sh = { "shfmt" },
	},
	format_on_save = {
		timeout_ms = 5000,
		lsp_format = "fallback",
	},

	-- formatters = {
	-- 	my_c_formatter = {
	-- 		command = "clang-format", -- Use clang-format as the command
	-- 		args = { "--style=llvm", "--use-tabs", "--indent-width=4", "--stdin-from-filename", "$FILENAME" },
	-- 		stdin = true, -- Read from stdin
	-- 		exit_codes = { 0, 1 }, -- Success exit codes
	-- 		cwd = require("conform.util").root_file({ ".editorconfig", "package.json" }),
	-- 		require_cwd = true,
	-- 		prepend_args = { "--use-tabs" },
	-- 		-- Define the custom formatter
	-- 	},
	-- },
})

-- Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args) require("conform").format({ bufnr = args.buf }) end,
})

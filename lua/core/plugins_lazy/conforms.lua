return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre", "BufNewFile" }, -- lazy load on save or new file
		config = function()
			local conform = require("conform")

			local function tab_formatter_c(command)
				return {
					command = command,
					args = { "--style", "{UseTab: ForIndentation, IndentWidth: 4}" },
				}
			end

			local uncrustify_args = {
				command = "uncrustify",
				stdin = false,
				args = { "-c", os.getenv("HOME") .. "/uncrustify.cfg", "--replace", "--no-backup", "$FILENAME" },
			}

			conform.setup({
				formatters = {
					black = { prepend_args = { "--line-length", "140" } },
					stylua = {
						prepend_args = {
							"--column-width",
							"151",
							"--indent-type",
							"Tabs",
							"--indent-width",
							"4",
							"--collapse-simple-statement",
							"FunctionOnly",
						},
					},
					prettier = { prepend_args = { "--tab-width", "4", "--use-tabs", "false" } },
					uncrustify = uncrustify_args,
					clang_format = tab_formatter_c("clang-format"),
					-- add more formatters here
				},
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "black" },
					c = { "clang_format" },
					cpp = { "clang_format" },
					javascript = { "prettier", stop_after_first = true },
					-- add more filetypes here
				},
				format_on_save = {
					timeout_ms = 5000,
					lsp_format = "fallback",
				},
				disabled = { "python" },
			})

			-- Auto format on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args) conform.format({ bufnr = args.buf }) end,
			})
		end,
	},
}

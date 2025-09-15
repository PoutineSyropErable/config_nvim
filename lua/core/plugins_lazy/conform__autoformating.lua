return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre", "BufNewFile" }, -- lazy load on save or new file
		config = function()
			local conform = require("conform")
			local function tab_formatter_c(command)
				-- Determine git root
				local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				local style_arg

				if git_root and vim.fn.filereadable(git_root .. "/.clang-format") == 1 then
					style_arg = "-style=file"
				else
					-- fallback style
					style_arg = "-style={UseTab: ForIndentation, IndentWidth: 4}"
				end

				return {
					command = command,
					args = { style_arg },
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

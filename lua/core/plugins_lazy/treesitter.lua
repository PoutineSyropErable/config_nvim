return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {}, -- start empty, no upfront installs
				-- ensure_installed = { "asm", "c", "cpp", "lua", "rust", "vim", "html", "python", "java", "css", "xml" },
				sync_install = false,
				auto_install = false, -- disable auto_install here since we'll handle manually
				highlight = { enable = true },
				indent = { enable = true, disable = { "latex" } },
			})

			local parsers = require("nvim-treesitter.parsers")
			local install = require("nvim-treesitter.install")

			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				callback = function()
					local ft = vim.bo.filetype
					if ft and not parsers.has_parser(ft) then
						-- Install parser asynchronously if missing
						vim.schedule(function() install.install(ft) end)
					end
				end,
				-- Possbily skips the first file, and race condition.
				-- TODO.
			})

			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = "*.dump",
				callback = function() vim.bo.filetype = "asm" end,
			})
		end,
	},
}

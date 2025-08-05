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
				highlight = {
					enable = true,
					-- additional_vim_regex_highlighting = false, -- maybe not necessary
				},
				indent = { enable = true, disable = { "latex" } },
			})

			local parsers = require("nvim-treesitter.parsers")
			local install = require("nvim-treesitter.install")

			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				callback = function()
					local ft = vim.bo.filetype

					-- Prevent trying to install unsupported or unknown filetypes
					if not ft or ft == "" then
						return
					end

					local lang = parsers.ft_to_lang(ft)

					-- Don't install if no parser exists for this language
					if not parsers.get_parser_configs()[lang] then
						return
					end

					-- Only install if not already available
					if not parsers.has_parser(lang) then
						vim.schedule(function() install.install(lang) end)
					end
				end,
			})

			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = "*.dump",
				callback = function() vim.bo.filetype = "asm" end,
			})
		end,
	},
}

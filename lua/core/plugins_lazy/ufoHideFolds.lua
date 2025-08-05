return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
		},
		lazy = true,
		keys = {
			{ "<leader>ze", function() require("ufo").openFoldsExceptKinds({}) end, { desc = "Open fold under cursor" } },
			{ "<leader>zq", function() require("ufo").closeFoldsWith(1) end, { desc = "Close fold under cursor" } },
			{ "<leader>zE", function() require("ufo").openAllFolds() end, { desc = "Open all folds" } },
			{ "<leader>zQ", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" } },
		},
		config = function()
			-- Fold settings
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Capabilities for LSP
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}

			local lspconfig = require("lspconfig")
			local servers = require("lspconfig.util").available_servers()
			for _, server in ipairs(servers) do
				lspconfig[server].setup({
					capabilities = capabilities,
					-- Optional: add more LSP setup config here per server
				})
			end

			-- UFO Setup
			require("ufo").setup({
				provider_selector = function(_, filetype)
					if filetype == "NeogitStatus" then
						return ""
					end
					return { "lsp", "indent" }
				end,
			})

			-- Keymaps
			local keymap = vim.keymap.set
			local ufo = require("ufo")

			keymap("n", "<leader>zE", ufo.openAllFolds, { desc = "Open all folds" })
			keymap("n", "<leader>zQ", ufo.closeAllFolds, { desc = "Close all folds" })
			keymap("n", "<leader>ze", function() ufo.openFoldsExceptKinds({}) end, { desc = "Open fold under cursor" })
			keymap("n", "<leader>zq", function() ufo.closeFoldsWith(1) end, { desc = "Close fold under cursor" })

			keymap("n", "<leader>zK", function()
				local winid = ufo.peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end, { desc = "Peek Fold" })
			keymap(
				"n",
				"<leader>zn",
				function() vim.fn.search("^\\zs.\\{-}\\ze\\n\\%($\\|\\s\\{2,}\\)", "W") end,
				{ desc = "Jump to next closed fold" }
			)
			keymap(
				"n",
				"<leader>zb",
				function() vim.fn.search("^\\zs.\\{-}\\ze\\n\\%($\\|\\s\\{2,}\\)", "bW") end,
				{ desc = "Jump to previous closed fold" }
			)
		end,
	},
}

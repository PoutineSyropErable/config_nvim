return {
	{
		"OXY2DEV/markview.nvim",
		lazy = false, -- recommended to load immediately
		-- the plugins is lazy loaded by using it's own lazy implementation. So, there's no point to double lazy it
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			-- Set global Vim variables for markview
			vim.g.mkdp_theme = "light"
			vim.g.mkdp_command_for_global = 1

			local keymap = vim.keymap
			-- makes keymap seting easier
			local function opts(desc) return { noremap = true, silent = true, desc = desc } end

			---------------  ✍️ Markdown Preview Toggle
			keymap.set("n", "<leader>mt", ":Markview Toggle<CR>", opts("Toggle Markdown Preview"))
			keymap.set("n", "<leader>ms", ":Markview Start<CR>", opts("Start Markdown Preview"))
			keymap.set("n", "<leader>me", ":Markview Enable<CR>", opts("Enable Markdown Preview Globally"))
			keymap.set("n", "<leader>md", ":Markview Disable<CR>", opts("Disable Markdown Preview Globally"))
			keymap.set("n", "<leader>ma", ":Markview attach<CR>", opts("Attach to Current Buffer"))
			keymap.set("n", "<leader>mx", ":Markview detach<CR>", opts("Detach from Current Buffer"))
			keymap.set("n", "<leader>mp", ":Markview Render<CR>", opts("Render Markdown Preview"))
			keymap.set("n", "<leader>mc", ":Markview Clear<CR>", opts("Clear Markdown Preview"))

			-- 🔄 Split View Mode
			keymap.set("n", "<leader>mo", ":Markview splitOpen<CR>", opts("Open Split View"))
			keymap.set("n", "<leader>mC", ":Markview splitClose<CR>", opts("Close Split View"))
			keymap.set("n", "<leader>mT", ":Markview splitToggle<CR>", opts("Toggle Split View"))
			keymap.set("n", "<leader>mr", ":Markview splitRedraw<CR>", opts("Redraw Split View"))

			-- 🔍 Debugging / Logs
			keymap.set("n", "<leader>mDx", ":MarkView traceExport<CR>", opts("Export Trace Logs"))
			keymap.set("n", "<leader>mDs", ":MarkView traceShow<CR>", opts("Show Trace Logs"))

			-- Setup autocmd for User event 'MarkviewAttach'
			vim.api.nvim_create_autocmd("User", {
				pattern = "MarkviewAttach",
				callback = function(event)
					local data = event.data
					-- vim.print(data)
				end,
			})
		end,
	},
}

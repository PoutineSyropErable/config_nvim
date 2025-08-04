return {
	{
		"lervag/vimtex",
		lazy = false, -- Required for proper functionality (especially inverse search)
		init = function()
			-- Basic configuration (runs before plugin loads)
			vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_compiler_method = "latexmk"

			-- Advanced compilation settings
			vim.g.vimtex_compiler_latexmk = {
				build_dir = vim.fn.expand("~/.texfiles/"),
				out_dir = ".", -- Output PDF in same directory as source
				options = {
					"-pdf",
					"-interaction=nonstopmode",
					"-synctex=1",
					"-file-line-error",
					"-shell-escape",
				},
				callback = 1, -- Enable callbacks for async compilation
			}

			-- Enable features
			vim.g.vimtex_fold_enabled = 1
			vim.g.vimtex_indent_enabled = 1
			vim.g.vimtex_syntax_enabled = 1
			vim.g.vimtex_quickfix_mode = 0 -- Don't auto-open quickfix
		end,
		config = function()
			-- Keymaps configuration (runs after plugin loads)
			local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = "VimTeX: " .. desc }) end

			-- Compilation and viewing
			map("n", "<leader>ll", "<cmd>VimtexCompile<cr>", "Start/Continue compilation")
			map("n", "<leader>lL", "<cmd>VimtexCompileSelected<cr>", "Compile selected text")
			map("n", "<leader>lk", "<cmd>VimtexStop<cr>", "Stop current compilation")
			map("n", "<leader>lK", "<cmd>VimtexStopAll<cr>", "Stop all sessions")
			map("n", "<leader>lv", "<cmd>VimtexView<cr>", "View PDF")

			-- Cleaning and maintenance
			map("n", "<leader>lc", "<cmd>VimtexClean<cr>", "Clean auxiliary files")
			map("n", "<leader>lC", "<cmd>VimtexClean!<cr>", "Full clean (includes PDF)")

			-- Navigation and information
			map("n", "<leader>lt", "<cmd>VimtexTocOpen<cr>", "Open table of contents")
			map("n", "<leader>lT", "<cmd>VimtexTocToggle<cr>", "Toggle table of contents")
			map("n", "<leader>le", "<cmd>VimtexErrors<cr>", "Show errors")
			map("n", "<leader>lo", "<cmd>VimtexCompileOutput<cr>", "Show compilation output")
			map("n", "<leader>lq", "<cmd>VimtexLog<cr>", "Show log file")

			-- Project management
			map("n", "<leader>ls", "<cmd>VimtexToggleMain<cr>", "Toggle main file")
			map("n", "<leader>lx", "<cmd>VimtexReload<cr>", "Reload project")
			map("n", "<leader>lX", "<cmd>VimtexReloadState<cr>", "Reload state")

			-- Advanced features
			map("n", "<leader>la", "<cmd>VimtexContextMenu<cr>", "Context menu")
			map("n", "<leader>li", "<cmd>VimtexInfo<cr>", "Show info")
			map("n", "<leader>lI", "<cmd>VimtexInfo!<cr>", "Show full info")
			map("n", "<leader>lG", "<cmd>VimtexStatusAll<cr>", "Status for all sessions")
			map("n", "<leader>lm", "<cmd>VimtexImapsList<cr>", "List input mappings")
		end,
	},
}

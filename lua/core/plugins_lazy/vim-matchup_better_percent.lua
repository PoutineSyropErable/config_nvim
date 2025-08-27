return {
	"andymass/vim-matchup",
	init = function()
		-- modify your configuration vars here
		vim.g.matchup_treesitter_stopline = 500

		-- or call the setup function provided as a helper. It defines the
		-- configuration vars for you
		require("match-up").setup({
			treesitter = {
				stopline = 500,
			},
		})

		-- in your lazy.nvim config
		-- Disable all default key mappings
		-- vim.g.matchup_override_vimtex = 0 -- optional, only for vimtex
		-- vim.g.matchup_override_default_mapping = 1
		-- vim.g.matchup_matchparen_enabled = 1
		--
		-- vim.g.matchup_override_vimtex = 0
		-- vim.g.matchup_override_default_mapping = 1
		vim.api.nvim_del_keymap("x", "i%")
	end,
	-- or use the `opts` mechanism built into `lazy.nvim`. It calls
	-- `require('match-up').setup` under the hood
	---@type matchup.Config
	opts = {
		treesitter = {
			stopline = 500,
		},
	},
}

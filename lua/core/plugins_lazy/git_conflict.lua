local use_git_conflict = require("_before.pre_config").use_git_confict

if not use_git_conflict then
	return {
		{
			"PoutineSyropErable/meld-like-merge.nvim",
			config = function() require("meld_like_merge").setup({}) end,
		},
	}
end

return {
	"akinsho/git-conflict.nvim",
	event = { "BufReadPost" },
	config = function()
		require("git-conflict").setup({
			default_mappings = false, -- Enable default keymaps
			disable_diagnostics = true, -- Disable LSP diagnostics during conflicts
			highlights = {
				incoming = "DiffAdd",
				current = "DiffText",
			},
		})

		-- Disable git-conflict in special git-related buffers
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "fugitive", "git", "gitcommit", "gitrebase" },
			callback = function() vim.b.git_conflict_disable = true end,
		})

		local conflict = require("git-conflict")
		local keymap = vim.keymap -- for clarity
		local opts = function(desc) return { noremap = true, silent = true, desc = desc } end

		-- Accept changes
		keymap.set("n", "<leader>ko", function() conflict.choose("ours") end, opts("Accept ours (HEAD)"))
		keymap.set("n", "<leader>kt", function() conflict.choose("theirs") end, opts("Accept theirs (incoming)"))
		keymap.set("n", "<leader>kb", function() conflict.choose("both") end, opts("Accept both"))
		keymap.set("n", "<leader>k0", function() conflict.choose("none") end, opts("Accept none"))

		-- Navigate between conflicts (any type)
		keymap.set("n", "<leader>kn", function() conflict.next() end, opts("Next conflict"))
		keymap.set("n", "<leader>kN", function() conflict.prev() end, opts("Previous conflict"))
	end,
}

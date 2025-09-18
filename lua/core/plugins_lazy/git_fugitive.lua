local fugitive = {
	lazy = true,
	"tpope/vim-fugitive",
	dependencies = {
		"tpope/vim-rhubarb",
	},
	cmd = { "Git", "Gdiffsplit", "Gblame", "Gwrite", "Gread", "Glog" },
	keys = {
		{ "<leader>Gf", ":Git<CR>", desc = "Git status (Fugitive)" },
		{ "<leader>Gm", ":Gvdiffsplit!<CR>", desc = "Git mergetool (vertical diff)" },
		{ "<leader>Gr", ":Gread<CR>", desc = "Reset file to Git index version" },
		{ "<leader>Gs", ":Gwrite<CR>", desc = "Stage current file" },
		{ "<leader>Gc", ":Git commit<CR>", desc = "Git commit (Fugitive)" },
		{ "<leader>Gl", ":Git log --oneline<CR>", desc = "Show Git log" },
		{ "<leader>GB", ":Git blame<CR>", desc = "Git blame (Fugitive)" },

		{ "<leader>Ga", ":Git add .<CR>", desc = "Stage all changes (git add .)" },
		{ "<leader>GA", ":Git add --all<CR>", desc = "Stage all changes (git add --all)" },
		{ "<leader>Gc", ":Git commit<CR>", desc = "Git commit (Fugitive)" },
		{
			"<leader>Gp",
			function()
				local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
				vim.cmd("Git push origin " .. branch)
			end,
			desc = "Push current branch to remote",
		},
	},
	config = function()
		-- Optional: disable fugitive’s default mappings if you want full control
		vim.g.fugitive_no_maps = 1
		local function opts(desc) return { noremap = true, silent = true, desc = desc } end
		vim.keymap.set("n", "<leader>Go", ":GBrowse<CR>", opts("Open file/line on GitHub (Rhubarb)"))
		vim.keymap.set("n", "<leader>Gb", ":GBrowse<CR>", opts("Open file/line on GitHub (Rhubarb)"))
	end,
}

local rhubarb = {
	"tpope/vim-rhubarb",
	dependencies = { "tpope/vim-fugitive" }, -- Rhubarb depends on Fugitive
	lazy = true,
	cmd = { "GBrowse" },
	keys = {
		{ "<leader>Go", ":GBrowse<CR>", desc = "Open file/line on GitHub (Rhubarb)" },
		{ "<leader>Gb", ":GBrowse<CR>", desc = "Open file/line on GitHub (Rhubarb)" },
	},
}

return { fugitive, rhubarb }

return {
	"kdheepak/lazygit.nvim",
	cmd = "LazyGit",
	keys = {
		{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazygit" },
	},
	config = function()
		-- no setup field
		local a = require("lazygit")
		local gu = require("_before.general_utils")

		local function opts(desc) return { noremap = true, silent = true, desc = desc } end

		vim.keymap.set("n", "<leader>lGc", a.lazygitconfig, opts("LazyGit: Config"))
		vim.keymap.set("n", "<leader>lGf", a.lazygitcurrentfile, opts("LazyGit: Current File"))
		vim.keymap.set("n", "<leader>lGx", a.lazygitfilter, opts("LazyGit: Filter"))
		vim.keymap.set("n", "<leader>lGm", a.lazygitfiltercurrentfile, opts("LazyGit: Filter Current File"))
		vim.keymap.set("n", "<leader>lGg", a.lazygitlog, opts("LazyGit: Log"))
		vim.keymap.set("n", "<leader>lGr", a.project_root_dir, opts("LazyGit: Project Root"))
	end,
}

-- {
--   lazygit = <function 1>,
--   lazygitconfig = <function 2>,
--   lazygitcurrentfile = <function 3>,
--   lazygitfilter = <function 4>,
--   lazygitfiltercurrentfile = <function 5>,
--   lazygitlog = <function 6>,
--   project_root_dir = <function 7>
-- }

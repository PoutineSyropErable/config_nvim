local function is_git_repo()
	local git_dir = vim.fn.finddir(".git", ".;")
	return git_dir ~= "" and git_dir ~= nil
end

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "nightfly",
	},
	sections = {
		lualine_a = {
			{
				"filename",
				path = 1,
			},
		},
	},
})

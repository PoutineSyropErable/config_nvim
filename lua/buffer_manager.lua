local function print_custom(...)
	local args = { ... }
	local parts = {}
	for i, v in ipairs(args) do
		parts[i] = tostring(v)
	end
	local msg = table.concat(parts, "\t")

	-- Use vim.notify to show as notification or just silent log
	vim.notify(msg, vim.log.levels.INFO)
end

local function get_buffer_plugins(use_bufferline)
	local barbar = {
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function() vim.g.barbar_auto_setup = false end,
	}

	local bufferline = { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" }

	-- Return both plugins
	if use_bufferline then
		print_custom("using bufferline")
		return bufferline
	else
		print_custom("using barbar")
		return barbar
	end
end

return get_buffer_plugins

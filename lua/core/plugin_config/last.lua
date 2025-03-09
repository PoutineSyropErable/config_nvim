vim.api.nvim_create_autocmd("TabEnter", {
	callback = function()
		local bufname = vim.api.nvim_buf_get_name(0) -- Get current buffer's full path
		if bufname ~= "" then
			local file_dir = vim.fn.fnamemodify(bufname, ":h") -- Extract directory
			vim.cmd("tcd " .. vim.fn.fnameescape(file_dir)) -- Change tab-local directory
			require("nvim-tree.api").tree.change_root(file_dir) -- Sync Nvim-Tree
			print("Changed tab directory to: " .. file_dir)
		else
			-- print("No active buffer, keeping previous tab directory.")
		end
	end,
})

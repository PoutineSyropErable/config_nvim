local gu = require("_before.general_utils")

vim.api.nvim_create_autocmd("TabEnter", {
	callback = function()
		local bufname = vim.api.nvim_buf_get_name(0) -- Get current buffer's full path
		if bufname ~= "" then
			local file_dir = vim.fn.fnamemodify(bufname, ":h") -- Extract directory
			vim.cmd("tcd " .. vim.fn.fnameescape(file_dir)) -- Change tab-local directory

			local tapi = package.loaded["nvim-tree.api"]
			if tapi and tapi.tree and tapi.tree.change_root then
				tapi.tree.change_root(file_dir) -- Sync Nvim-Tree, if available
			end

			gu.print_custom("Changed tab directory to: " .. file_dir)
		else
			-- gu.print_custom("No active buffer, keeping previous tab directory.")
		end
	end,
})

-- I actually use it with conform.lua

-- Python formatter
return {
	-- https://github.com/psf/black
	"psf/black",
	ft = "python",
	config = function()
		-- Automatically format file buffer when saving
		vim.api.nvim_create_autocmd({ "BufWritePre" }, {
			pattern = "*.py2",
			callback = function() vim.cmd("Black") end,
		})
	end,
}

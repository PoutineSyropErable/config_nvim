vim.api.nvim_create_autocmd("User", {
	pattern = "MarkviewAttach",
	callback = function(event)
		--- This will have all the data you need.
		local data = event.data

		vim.print(data)
	end,
})

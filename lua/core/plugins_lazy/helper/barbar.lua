local M = {}

--- Closes the current buffer or the tab (if only one buffer left)
function M.close_buffer_or_tab()
	local buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
	local tab_count = vim.fn.tabpagenr("$")

	if buf_count == 1 then
		if tab_count == 1 then
			vim.cmd("q")
		else
			vim.cmd("tabclose")
		end
	else
		local ok, bufremove = pcall(require, "mini.bufremove")
		if ok then
			bufremove.delete(0, false)
		else
			vim.notify("mini.bufremove not available", vim.log.levels.ERROR)
		end
	end
end

--- Force delete the current buffer
function M.force_close_buffer()
	local ok, bufremove = pcall(require, "mini.bufremove")
	if ok then
		bufremove.delete(0, false)
	else
		vim.notify("mini.bufremove not available", vim.log.levels.ERROR)
	end
end

function M.goto_buffer(buf_num) vim.cmd("BufferGoto " .. buf_num) end

return M

local function nohup() end

require("scope").setup({
	hooks = {
		-- Add custom logic to be run when entering or leaving a tab
		pre_tab_enter = nohup,
		post_tab_enter = nohup,
		pre_tab_leave = nohup,
		post_tab_leave = nohup,
		pre_tab_close = nohup,
		post_tab_close = nohup,
	},
})

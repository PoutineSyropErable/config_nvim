local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local Job = require("plenary.job")

-- Function to show files in Telescope and call the coroutine with the selected file
local function show_files_picker(files, co)
	vim.defer_fn(function()
		pickers
			.new({}, {
				prompt_title = "Select Executable",
				finder = finders.new_table({
					results = files,
					entry_maker = function(entry)
						return {
							value = entry.path,
							display = entry.name, -- Display the full name of the item
							ordinal = entry.name, -- Sort by name
						}
					end,
				}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(_, map)
					-- On selection, call the coroutine with the selected item
					map("i", "<CR>", function(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						coroutine.resume(co, selection.value) -- Resume the coroutine with the selected file
						actions.close(prompt_bufnr)
					end)
					return true
				end,
			})
			:find()
	end, 0) -- Delay by 0ms to ensure it happens after the current loop
end

-- Function to get all files using 'fd' and pass the result to Telescope
local function get_files_using_fd()
	local files = {}

	-- Use plenary.job to run 'fd' command and collect the results
	Job:new({
		command = "fd",
		args = { "--type", "f", "--hidden", "--follow", "--exclude", ".git" }, -- Adjust as necessary
		cwd = vim.fn.getcwd(), -- Current working directory
		on_exit = function(j, return_val)
			if return_val == 0 then
				local output = j:result()

				-- Collect files into the `files` table
				for _, line in ipairs(output) do
					table.insert(files, {
						name = line,
						path = line,
					})
				end
				-- Pass the result to Telescope to display the files
				-- The coroutine will be resumed once the selection is made
				show_files_picker(files, coroutine.running()) -- Pass the current coroutine
			else
				print("Error: 'fd' command failed")
			end
		end,
	}):start()
end

-- Synchronous function to get the executable path
local function find_executable()
	-- Create a coroutine to handle the asynchronous file selection
	local co = coroutine.create(function()
		local path = nil

		-- Get files and show the Telescope picker
		get_files_using_fd()

		-- Wait for the selection to be made (the coroutine will be resumed once selection is done)
		while path == nil do
			coroutine.yield() -- Yield the coroutine and wait for the selection
		end

		return path -- Return the selected file path
	end)

	-- Start the coroutine and resume it to handle the interaction
	local path = coroutine.resume(co)

	-- Return the result after the user selects a file
	return path
end

-- Call the simplified find_executable function and print the selected path
local executable_path = find_executable()

-- Check if executable_path is valid before concatenating
if executable_path and executable_path ~= false then
	print("Selected executable path: " .. executable_path)
else
	print("No executable selected.")
end
if executable_path then
	print("Selected executable path: " .. executable_path)
else
	print("No executable selected.")
end

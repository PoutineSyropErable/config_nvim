local M = {}

-- root markers
local ROOT_MARKERS = {
	".git",
	".hg",
	".svn",
	"Makefile",
	"CMakeLists.txt",

	-- Python
	"pyproject.toml",
	"Pipfile",
	"requirements.txt",
	"setup.py",
	"setup.cfg",

	-- C/C++
	"compile_commands.json",
	"meson.build",
	"configure.ac",
	"autogen.sh",

	-- Java
	"pom.xml",
	"build.gradle",
	"settings.gradle",
	".classpath",
	".project",

	-- Rust
	"Cargo.toml",
}

--- Walk up from a directory until a root marker is found
--- @param start_dir string
--- @param debug boolean
local function find_project_root_lua(start_dir, debug)
	local uv = vim.loop
	local dir = uv.fs_realpath(start_dir)
	if not dir then
		return nil
	end

	while dir do
		for _, marker in ipairs(ROOT_MARKERS) do
			local marker_path = dir .. "/" .. marker
			if uv.fs_stat(marker_path) then
				if debug then
					vim.notify("✅ Found root marker: " .. marker_path, vim.log.levels.DEBUG)
				end
				return dir
			end
		end

		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			-- reached filesystem root
			break
		end
		dir = parent
	end

	if debug then
		vim.notify("⚠️ No project root found from: " .. start_dir, vim.log.levels.WARN)
	end
	return nil
end

function M.get_lsp_project_root()
	local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

	for _, client in ipairs(clients) do
		-- Try root_dir first
		if client.config and client.config.root_dir then
			return client.config.root_dir
		end

		-- Fallback to workspace_folders
		local folders = client.workspace_folders
		if folders and folders[1] then
			return vim.uri_to_fname(folders[1].uri)
		end
	end
	return nil -- fallback to cwd or manual override
end

--- Entry function: pick Lua method first, fallback to cwd
function M.find_project_root(debug)
	local buffer_path = vim.fn.expand("%:p")
	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")

	local root = M.get_lsp_project_root()
	if root then
		if debug then
			vim.notify("🔍 Using LSP project root: " .. root, vim.log.levels.DEBUG)
		end
		return root
	end

	root = find_project_root_lua(buffer_dir, debug)
	if root then
		if debug then
			vim.notify("🔍 Using the lua fpr: " .. root, vim.log.levels.DEBUG)
		end
		return root
	else
		if debug then
			vim.notify("ℹ️ Falling back to cwd: " .. vim.fn.getcwd(), vim.log.levels.INFO)
		end
		return vim.fn.getcwd()
	end
end

return M

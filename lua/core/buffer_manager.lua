local function get_buffer_plugins(use_bufferline)
    local barbar = {
        "romgrk/barbar.nvim",
        dependencies = {
            "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
            "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
        },
        init = function() vim.g.barbar_auto_setup = false end,
        opts = {
            animation = true,
            insert_at_end = true,
        },
    }

    local bufferline = {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                mode = "buffers",
                diagnostics = "nvim_lsp",
                separator_style = "slant",
                show_buffer_close_icons = true,
                show_close_icon = false,
            },
        },
    }

    local session_manager = {
        "Shatur/neovim-session-manager",
        dependencies = {},
        config = function()
            require("session_manager").setup({
                autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
            })
        end,
    }

    -- If using bufferline, make session manager depend on it
    if use_bufferline then
        session_manager.dependencies = { "akinsho/bufferline.nvim" }
    end

    -- Return both plugins
    return { use_bufferline and bufferline or barbar, session_manager }
end

return get_buffer_plugins


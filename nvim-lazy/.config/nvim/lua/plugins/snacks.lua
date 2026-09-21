return {
    {
        "folke/snacks.nvim",
        opts = function(_, opts)
            -- C-h/j/k/l is one motion across nvim splits and Herdr panes (see
            -- lua/plugins/herdr.lua), but snacks binds C-j/C-k buffer-locally
            -- to list_down/list_up in every picker window, and a buffer-local
            -- map beats the global one - so inside the explorer they walked the
            -- file list instead of leaving it. Unbind them. C-n/C-p are snacks'
            -- own aliases for the same two actions and stay bound, so the list
            -- loses nothing.
            --
            -- The input window is where you land when filtering, and it is in
            -- insert mode, which the global maps do not cover (they are normal
            -- mode only, so that C-h stays backspace when typing text). Bind
            -- the four there explicitly, scoped to this window: in a file
            -- picker the keys should move, not edit.
            local function move(dir)
                return function()
                    require("smart-splits")["move_cursor_" .. dir]()
                end
            end

            local nav = {
                ["<c-h>"] = false,
                ["<c-j>"] = false,
                ["<c-k>"] = false,
                ["<c-l>"] = false,
            }

            local nav_insert = {
                ["<c-h>"] = { move("left"), mode = { "i", "n" }, desc = "Go to left window/pane" },
                ["<c-j>"] = { move("down"), mode = { "i", "n" }, desc = "Go to lower window/pane" },
                ["<c-k>"] = { move("up"), mode = { "i", "n" }, desc = "Go to upper window/pane" },
                ["<c-l>"] = { move("right"), mode = { "i", "n" }, desc = "Go to right window/pane" },
            }

            return vim.tbl_deep_extend("force", opts or {}, {
                indent = {
                    enabled = true,
                    animate = { enabled = false },
                },
                scope = {
                    enabled = true,
                    animate = { enabled = false },
                },
                scroll = {
                    enabled = false, -- IMPORTANT
                },
                picker = {
                    win = {
                        input = { keys = nav_insert },
                        list = { keys = nav },
                    },
                },
            })
        end,
    },
}

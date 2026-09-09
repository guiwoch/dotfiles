return {
    "tpope/vim-fugitive",
    lazy = false,
    keys = {
        { "<leader>gs", "<cmd>vertical Git<cr>", desc = "Git Status (fugitive)" },
        { "<leader>Gc", "<cmd>vertical Git commit<cr>", desc = "Git commit" },
        { "<leader>Gd", "<cmd>vertical Gdiffsplit<cr>", desc = "Git diff split" },
        { "<leader>Gw", "<cmd>Gwrite<cr>", desc = "Git stage file" },
        { "<leader>GR", "<cmd>Gread<cr>", desc = "Git discard changes" },
    },
    init = function()
        -- Set width for fugitive buffers
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "fugitive",
            callback = function()
                vim.cmd("vertical resize 80")
            end,
        })

        --     -- Disable LSP in fugitive buffers to avoid URI errors
        --     vim.api.nvim_create_autocmd("BufReadCmd", {
        --         pattern = "fugitive://*",
        --         callback = function()
        --             vim.lsp.stop_client(vim.lsp.get_clients())
        --         end,
        --     })
    end,
}

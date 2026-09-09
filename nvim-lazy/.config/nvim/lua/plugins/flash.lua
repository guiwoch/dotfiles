return {
    "folke/flash.nvim",
    keys = {
        -- remove LazyVim defaults that overide default ones
        { "s", false },
        { "S", false },

        {
            "gh",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "Flash jump",
        },

        {
            -- treesitter
            "gH",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash Treesitter jump",
        },
    },
}

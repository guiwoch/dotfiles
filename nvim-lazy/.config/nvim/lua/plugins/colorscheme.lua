return {
    -- Local fork of blazkowolf/gruber-darker.nvim with highlights adjusted
    -- to match the original Emacs theme more closely.
    {
        "gruber-darker.nvim",
        dir = vim.fn.stdpath("config") .. "/vendors/gruber-darker.nvim",
        lazy = false,
        priority = 1000,
        init = function()
            vim.cmd.colorscheme("gruber-darker")
        end,
    },
    -- Vimscript port — comment out the block above and uncomment this to compare
    -- {
    --     "ThunderBoltCODMYT/gruber-darker.vim",
    --     lazy = false,
    --     priority = 1000,
    --     config = function()
    --         vim.cmd("colorscheme gruber-darker")
    --     end,
    -- },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "gruber-darker",
        },
    },
}

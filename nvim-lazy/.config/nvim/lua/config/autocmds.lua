-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- -- Disable all LSP reference highlighting completely
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
    end,
})

-- LSP hover/signature floats get `filetype=markdown`, which trips LazyVim's
-- `wrap_spell` autocmd and puts spell squiggles under every type name.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(event)
        if vim.bo[event.buf].buftype == "nofile" then
            vim.opt_local.spell = false
        end
    end,
})

-- Autosave for ~/scratch and the :Note command (see lua/gw/scratch.lua).
require("gw.scratch").setup()

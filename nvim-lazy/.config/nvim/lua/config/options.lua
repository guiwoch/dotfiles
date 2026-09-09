-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting

-- STOP Neovim from vandalizing the system clipboard: without this, EVERY
-- (dd, dw, c, x, etc.) goes to the system clipboard.
vim.opt.clipboard = ""

-- Keep Copilot out of the completion menu. LazyVim keys the whole AI setup off
-- this: true puts Copilot in as a blink source (score_offset 100, so it sorts
-- above every LSP item and steals <C-y>), false gives inline ghost text
-- accepted with <Tab> instead, leaving the menu purely LSP.
vim.g.ai_cmp = false

-- vim.g.lazyvim_cmp = "nvim-cmp"
vim.opt.updatetime = 50
vim.o.cmdheight = 1
vim.o.showmode = true
vim.o.laststatus = 1
-- vim.g.minipairs_disable = true

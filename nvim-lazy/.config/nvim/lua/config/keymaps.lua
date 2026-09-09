-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>o", "<cmd>Oil<CR>", { desc = "Open Oil file manager" })

vim.keymap.set("n", "gl", function()
    vim.diagnostic.open_float(nil, {
        focus = false,
        scope = "cursor",
        border = "rounded",
    })
end, { desc = "Show diagnostics under cursor" })

-- Nvim 0.12 ships a builtin ":lsp" command, so nvim-lspconfig no longer defines
-- ":LspRestart" at all (see the early return in its plugin/lspconfig.lua).
-- ":lsp restart" restarts every client attached to the current buffer.
-- Diagnostics are cleared first: a restarting server does not retract the stale
-- ones it already published, so they would otherwise hang around until it
-- happens to republish that file.
vim.keymap.set("n", "<leader>r", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        vim.notify("No LSP client attached to this buffer", vim.log.levels.WARN)
        return
    end
    vim.diagnostic.reset()
    vim.cmd.lsp("restart")
    vim.notify("Restarting " .. table.concat(
        vim.tbl_map(function(c)
            return c.name
        end, clients),
        ", "
    ), vim.log.levels.INFO)
end, { desc = "Restart LSP (current buffer)" })

-- Apply the fix for the diagnostic under the cursor without the code-action menu
vim.keymap.set({ "n", "v" }, "ga", function()
    require("gw.lspfix").fix()
end, { desc = "Apply quickfix (diagnostic under cursor)" })


-- Remove default Alt mappings (conflict with window manager)
vim.keymap.del("n", "<A-j>")
vim.keymap.del("n", "<A-k>")
vim.keymap.del("v", "<A-j>")
vim.keymap.del("v", "<A-k>")
vim.keymap.del("i", "<A-j>")
vim.keymap.del("i", "<A-k>")


-- Toggle Copilot entirely (off for leetcode / competitive programming).
-- Copilot is no longer a blink source, so this stops/starts the client itself
-- rather than filtering a completion source.
vim.api.nvim_create_user_command("CopilotToggle", function()
    local command = require("copilot.command")
    vim.g.copilot_off = not vim.g.copilot_off
    if vim.g.copilot_off then
        command.disable()
    else
        command.enable()
    end
    vim.notify("Copilot " .. (vim.g.copilot_off and "disabled" or "enabled"), vim.log.levels.INFO)
end, { desc = "Toggle Copilot" })

vim.keymap.set("n", "<leader>ct", "<cmd>CopilotToggle<CR>", { desc = "Toggle Copilot" })

vim.keymap.set("n", "<leader>j", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<leader>k", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("v", "<leader>j", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<leader>k", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

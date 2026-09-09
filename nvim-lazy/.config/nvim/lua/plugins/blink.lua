return {
    "saghen/blink.cmp",
    opts = {
        -- NO presets, ever
        keymap = {
            preset = "none",
            ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-n>"] = { "select_next" },
            ["<C-p>"] = { "select_prev" },
            ["<C-y>"] = { "accept" },
            ["<CR>"] = {},
            -- Leave <Tab> alone. Without this LazyVim claims it for Copilot's
            -- ai_accept; Copilot is on <C-l> instead, so <Tab> just indents.
            ["<Tab>"] = { "fallback" },
        },

        completion = {
            list = {
                selection = {
                    preselect = true,
                    auto_insert = false,
                },
            },
            accept = {
                -- Insert "()" and place the cursor inside when accepting a
                -- function/method, instead of inserting signature placeholders.
                auto_brackets = { enabled = true },
            },
        },

        -- Show the signature (arg names/types) as a floating popup that
        -- highlights the current arg, instead of dumping it into the buffer.
        signature = { enabled = true },

        -- LSP + PATH only. Copilot is inline ghost text now (vim.g.ai_cmp =
        -- false in options.lua), not a completion source, so <C-y> can never
        -- land on a Copilot suggestion.
        -- A function, not a list: LazyVim's extras append their own sources
        -- (snippets, buffer, dadbod, ...) into a list, but cannot touch a
        -- function, so this stays exactly these two.
        sources = {
            default = function()
                return { "lsp", "path" }
            end,
        },
    },
}

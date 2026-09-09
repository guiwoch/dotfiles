return {
    {
        "ej-shafran/compile-mode.nvim",
        version = "^5.0.0",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = { "Compile", "Recompile" },
        keys = {
            { "<leader>mo", "<cmd>Compile<cr>", desc = "Compile: run command" },
            { "<leader>md", "<cmd>Recompile<cr>", desc = "Compile: rerun last command" },
        },
        config = function()
            ---@type CompileModeOpts
            vim.g.compile_mode = {
                bang_expansion = true,
                recompile_no_fail = true,
                -- ask_about_save = false,       -- skip "save buffers?" prompt before compiling
                -- focus_compilation_buffer = true, -- auto-jump to output on compile
                -- auto_jump_to_first_error = true, -- jump to first error after compile
                -- use_diagnostics = true,       -- show errors as nvim diagnostics instead of buffer
                -- use_pseudo_terminal = true,   -- enable color output (PTY)
            }
        end,
    },
}

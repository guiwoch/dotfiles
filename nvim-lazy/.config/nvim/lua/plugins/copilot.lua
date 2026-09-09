return {
    "zbirenbaum/copilot.lua",
    opts = {
        suggestion = {
            -- LazyVim ties this to vim.g.ai_cmp and leaves the ghost text up
            -- while the completion menu is open. Hide it instead: when the
            -- blink menu is showing, that menu is what you are looking at.
            hide_during_completion = true,
            keymap = {
                -- No Alt anywhere: those belong to the window manager.
                accept = "<C-l>",
                -- "." sits next to "l", so full accept and word-by-word accept
                -- are neighbours. Needs a terminal that speaks the Kitty
                -- keyboard protocol to send Ctrl+.  - WezTerm, kitty and
                -- Ghostty all do; a legacy terminal would drop it silently.
                accept_word = "<C-.>",
                accept_line = false,
                -- Cycling suggestions is off because every sensible key was
                -- either Alt (WM) or already taken by blink. Set these to a
                -- key you like if you ever want them back.
                next = false,
                prev = false,
                dismiss = "<C-]>",
            },
        },
    },
}

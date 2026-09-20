return {
    "christoomey/vim-tmux-navigator",
    -- Panes and splits are the same thing to the fingers: C-h/j/k/l crosses
    -- the nvim/tmux boundary in one motion. This is the only non-stock tmux
    -- binding in ~/.config/tmux/tmux.conf, because nothing stock can cross it.
    --
    -- Declared as `keys` rather than left to load order: LazyVim binds these
    -- to plain window navigation in normal mode and would otherwise win.
    -- No clash with copilot's <C-l> (plugins/copilot.lua) - that one is
    -- insert-mode, these are normal-mode.
    keys = {
        { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left window/pane" },
        { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower window/pane" },
        { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper window/pane" },
        { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right window/pane" },
    },
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
    },
}

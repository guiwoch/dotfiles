return {
    "mrjones2014/smart-splits.nvim",
    -- Panes and splits are the same thing to the fingers: C-h/j/k/l crosses
    -- the nvim/tmux boundary in one motion. This is the only non-stock tmux
    -- binding in ~/.config/tmux/tmux.conf, because nothing stock can cross it.
    --
    -- Replaces vim-tmux-navigator, which decided "am I at the edge of nvim?"
    -- by comparing winnr() before and after a wincmd. That is unanswerable from
    -- a floating window - snacks' explorer and pickers are floats, so the wincmd
    -- always dropped focus into the window underneath and the key was never
    -- forwarded: C-h could not leave the explorer. smart-splits knows about
    -- floats that behave like sidebars (utils.is_embedded_floating_window,
    -- which checks zindex < 50) and hands the key to tmux when such a float is
    -- at the screen edge.
    --
    -- Not lazy-loaded on purpose: the plugin sets the pane-local @pane-is-vim
    -- option that tmux.conf tests, and that has to be set before the first key,
    -- not by it.
    lazy = false,
    -- Read before the plugin's own bootstrap, which is what sets @pane-is-vim.
    -- Naming tmux instead of letting it autodetect: autodetection reads
    -- TERM_PROGRAM, which a pane spawned outside an attached client does not
    -- always have, and a miss is silent - the tmux side simply stops forwarding.
    init = function()
        vim.g.smart_splits_multiplexer_integration = "tmux"
    end,
    opts = {
        -- Default is 'wrap', which sends C-j at the bottom window back to the
        -- top one. Movement should only ever move in the direction pressed, so
        -- stop when there is nothing there - in nvim or in tmux.
        at_edge = "stop",
    },
    keys = {
        { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Go to left window/pane" },
        { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Go to lower window/pane" },
        { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Go to upper window/pane" },
        { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Go to right window/pane" },
    },
}

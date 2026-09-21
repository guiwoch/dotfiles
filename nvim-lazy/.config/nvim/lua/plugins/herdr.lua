return {
    "mrjones2014/smart-splits.nvim",
    -- Panes and splits are the same thing to the fingers: C-h/j/k/l crosses the
    -- nvim/Herdr boundary in one motion. Herdr's own key map is unconditional -
    -- a chord bound in its [keys] never reaches the pane - so C-h/j/k/l is
    -- deliberately NOT bound there, and the innermost program that understands
    -- the key does the moving: nvim walks its splits and calls `herdr pane
    -- focus` at its edge (this plugin's herdr backend), zsh does the same from
    -- the prompt (dotfiles/zsh/herdr.zsh).
    --
    -- Replaces vim-tmux-navigator, which decided "am I at the edge of nvim?"
    -- by comparing winnr() before and after a wincmd. That is unanswerable from
    -- a floating window - snacks' explorer and pickers are floats, so the wincmd
    -- always dropped focus into the window underneath and the key was never
    -- forwarded: C-h could not leave the explorer. smart-splits knows about
    -- floats that behave like sidebars (utils.is_embedded_floating_window,
    -- which checks zindex < 50; snacks' picker windows sit at 33) and hands the
    -- key to the multiplexer when such a float is at the screen edge.
    --
    -- Inside those floats snacks also binds C-j/C-k buffer-locally to
    -- list_down/list_up, which beats these global maps - lua/plugins/snacks.lua
    -- unbinds them so vertical motion works in the explorer too.
    --
    -- Not lazy-loaded on purpose: the plugin's bootstrap is what tells the
    -- multiplexer an nvim lives in this pane, and that has to happen before the
    -- first key, not by it.
    lazy = false,
    -- Read before the plugin's own bootstrap.
    init = function()
        -- Pick the multiplexer actually hosting this nvim. Autodetection reads
        -- TERM_PROGRAM, which a pane spawned outside an attached client does
        -- not always have, and a miss is silent. Both environments set an
        -- unambiguous variable, so test those instead.
        --
        -- tmux first, because it is the innermost one when both are around: a
        -- tmux pane inside Herdr still inherits HERDR_ENV, and handing that
        -- nvim to the herdr backend would leave tmux's @pane-is-vim unset, so
        -- tmux would eat C-h before nvim ever saw it.
        if vim.env.TMUX ~= nil and vim.env.TMUX ~= "" then
            vim.g.smart_splits_multiplexer_integration = "tmux"
        elseif vim.env.HERDR_ENV ~= nil and vim.env.HERDR_ENV ~= "" then
            vim.g.smart_splits_multiplexer_integration = "herdr"
        else
            vim.g.smart_splits_multiplexer_integration = false
        end
    end,
    opts = {
        -- Default is 'wrap', which sends C-j at the bottom window back to the
        -- top one. Movement should only ever move in the direction pressed, so
        -- stop when there is nothing there - in nvim or in Herdr.
        at_edge = "stop",
    },
    keys = {
        { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Go to left window/pane" },
        { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Go to lower window/pane" },
        { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Go to upper window/pane" },
        { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Go to right window/pane" },
    },
}

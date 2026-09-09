local Highlight = require("gruber-darker.highlight")
local gruber_hl = require("gruber-darker.highlights.colorscheme").highlights

---@type HighlightsProvider
local M = {
	highlights = {},
}

function M.setup()
	for _, value in pairs(M.highlights) do
		value:setup()
	end
end

-- Snacks picker / explorer highlights.
-- These are set before snacks.nvim loads (colorscheme has priority=1000).
-- Snacks registers its defaults with `default=true`, so it won't override these.

-- Untracked files: snacks defaults to NonText (bg+4 = #52494e, nearly black).
-- Use quartz instead, matching dired-ignored in the original Emacs theme.
M.highlights.git_untracked = Highlight.new("SnacksPickerGitStatusUntracked", { link = gruber_hl.quartz })

-- Dir component of paths in search results: also NonText by default, too dark.
M.highlights.dir = Highlight.new("SnacksPickerDir", { link = gruber_hl.quartz })

return M

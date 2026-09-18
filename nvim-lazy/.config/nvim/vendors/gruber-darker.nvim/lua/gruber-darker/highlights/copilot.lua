local Highlight = require("gruber-darker.highlight")
local c = require("gruber-darker.palette")
local opts = require("gruber-darker.config").get_opts()

---@type HighlightsProvider
local M = {
	highlights = {},
}

function M.setup()
	for _, value in pairs(M.highlights) do
		value:setup()
	end
end

-- copilot.lua links its ghost text to Comment, which makes a suggestion
-- indistinguishable from the brown comment on the line above it. Quartz is
-- muted enough to stay in the background but is a different hue, so at a
-- glance you can tell "not yet written" from "written and commented out".
--
-- copilot.lua only sets its own link when the group is still empty, and the
-- colorscheme has priority=1000, so these are already defined by the time it
-- looks - same arrangement as the snacks highlights.

---Inline ghost text of the current suggestion
M.highlights.suggestion = Highlight.new("CopilotSuggestion", { fg = c.quartz, italic = opts.italic.comments })

---The "1/3"-style counter shown next to a suggestion, and in the panel
M.highlights.annotation = Highlight.new("CopilotAnnotation", { fg = c["niagara-1"] })

return M

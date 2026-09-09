-- Apply an LSP quickfix without going through the full code-action menu.
--
-- `vim.lsp.buf.code_action()` asks the server for *everything* available at the
-- cursor (refactors, "Suppress or configure issues", "Fix all occurrences",
-- ...), which for Roslyn is a wall of options. Here we ask only for the
-- "quickfix" actions belonging to one diagnostic, drop the suppress/configure
-- noise, and let `apply = true` run it straight away when a single fix is left.
local M = {}

-- Titles that are technically quickfixes but never what you want when you hit
-- "fix this".
local noise = {
    "^suppress",
    "^configure ",
    "suppress or configure",
    "^fix all",
    "in suppression file",
}

---@param action lsp.CodeAction|lsp.Command
local function is_real_fix(action)
    local title = (action.title or ""):lower()
    for _, pattern in ipairs(noise) do
        if title:match(pattern) then
            return false
        end
    end
    return true
end

-- The diagnostic the cursor sits in, or else the first one on the line, so the
-- mapping works from anywhere on the line (and from a Trouble jump).
local function diagnostic_at_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local lnum, col = cursor[1] - 1, cursor[2]

    local candidates = vim.tbl_filter(function(d)
        -- Only LSP diagnostics carry the payload the server needs back.
        return d.user_data and d.user_data.lsp
    end, vim.diagnostic.get(0, { lnum = lnum }))

    for _, d in ipairs(candidates) do
        local end_col = d.end_col or d.col
        if col >= d.col and (col < end_col or d.col == end_col) then
            return d
        end
    end
    return candidates[1]
end

--- Apply the quickfix for the diagnostic under the cursor.
--- In visual mode, quickfix the selection instead.
function M.fix()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "v" or mode == "V" then
        vim.lsp.buf.code_action({
            apply = true,
            context = { only = { "quickfix" } },
            filter = is_real_fix,
        })
        return
    end

    local d = diagnostic_at_cursor()
    if not d then
        vim.notify("No diagnostic on this line", vim.log.levels.INFO)
        return
    end

    vim.lsp.buf.code_action({
        apply = true,
        -- mark-like indexing: 1-based row, 0-based col
        range = {
            start = { d.lnum + 1, d.col },
            ["end"] = { (d.end_lnum or d.lnum) + 1, d.end_col or d.col },
        },
        context = {
            only = { "quickfix" },
            diagnostics = { d.user_data.lsp },
        },
        filter = is_real_fix,
    })
end

return M

-- Scratch drafts and notes, paired with the `scratch` / `note` shell commands
-- in dotfiles/zsh/tools.zsh.
--
--   $SCRATCH_DIR/drafts/  throwaway writing, one file per session
--   $SCRATCH_DIR/notes/   named files that get appended to over time
--
-- Everything under $SCRATCH_DIR is written on every change, so `:q` never
-- asks. A draft that ends up empty is deleted when its buffer goes away.
-- `:Note <name>` files the current draft (or a range) into notes/<name>.md.
local M = {}

local root = vim.fs.normalize(vim.env.SCRATCH_DIR or "~/scratch")
local drafts = root .. "/drafts"
local notes = root .. "/notes"

local function path_of(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    return name ~= "" and vim.fs.normalize(name) or nil
end

local function is_under(path, dir)
    return path ~= nil and vim.startswith(path, dir .. "/")
end

local function is_blank(lines)
    for _, line in ipairs(lines) do
        if line:find("%S") then
            return false
        end
    end
    return true
end

-- Drop leading and trailing blank lines so filing a draft doesn't drag its
-- padding into the note.
local function trim(lines)
    local first, last = 1, #lines
    while first <= last and not lines[first]:find("%S") do
        first = first + 1
    end
    while last >= first and not lines[last]:find("%S") do
        last = last - 1
    end
    return vim.list_slice(lines, first, last)
end

local function note_path(name)
    if not name:find("%.%w+$") then
        name = name .. ".md"
    end
    return notes .. "/" .. name
end

local function complete_notes(arglead)
    local names = {}
    for name, kind in vim.fs.dir(notes) do
        if kind == "file" then
            local base = name:gsub("%.md$", "")
            if vim.startswith(base, arglead) then
                table.insert(names, base)
            end
        end
    end
    table.sort(names)
    return names
end

local function file_note(opts)
    local buf = vim.api.nvim_get_current_buf()
    local src = path_of(buf)
    local whole = opts.range == 0
    local lines = whole and vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        or vim.api.nvim_buf_get_lines(buf, opts.line1 - 1, opts.line2, false)
    lines = trim(lines)
    if #lines == 0 then
        vim.notify("Nothing to file", vim.log.levels.WARN)
        return
    end

    local target = note_path(opts.args)
    if target == src then
        vim.notify("Already in " .. opts.args, vim.log.levels.WARN)
        return
    end
    vim.fn.mkdir(notes, "p")

    -- If the note is open with unsaved edits, append in the buffer instead of
    -- behind its back on disk.
    local target_buf = vim.fn.bufnr(target)
    if target_buf ~= -1 and vim.api.nvim_buf_is_loaded(target_buf) then
        local existing = vim.api.nvim_buf_get_lines(target_buf, 0, -1, false)
        local start = is_blank(existing) and 0 or -1
        vim.api.nvim_buf_set_lines(target_buf, start, -1, false, lines)
        vim.api.nvim_buf_call(target_buf, function()
            vim.cmd("silent update")
        end)
    else
        vim.fn.writefile(lines, target, "a")
    end

    -- A whole draft now lives in the note: drop it. A range, or a file that
    -- isn't a draft, is left alone.
    local consumed = whole and is_under(src, drafts)
    vim.cmd.edit(vim.fn.fnameescape(target))
    vim.cmd("normal! G")
    if consumed then
        vim.api.nvim_buf_delete(buf, { force = true })
        os.remove(src)
    end
    vim.notify(("Filed %d line%s into %s"):format(#lines, #lines == 1 and "" or "s", opts.args))
end

function M.setup()
    local group = vim.api.nvim_create_augroup("gw_scratch", { clear = true })

    vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
        group = group,
        callback = function(ev)
            local path = path_of(ev.buf)
            if is_under(path, root) and vim.bo[ev.buf].buftype == "" and vim.bo[ev.buf].modified then
                vim.fn.mkdir(vim.fs.dirname(path), "p")
                vim.api.nvim_buf_call(ev.buf, function()
                    vim.cmd("silent! write")
                end)
            end
        end,
    })

    vim.api.nvim_create_autocmd({ "BufUnload", "VimLeavePre" }, {
        group = group,
        callback = function(ev)
            local path = path_of(ev.buf)
            if is_under(path, drafts) and vim.fn.filereadable(path) == 1 and is_blank(vim.fn.readfile(path)) then
                os.remove(path)
            end
        end,
    })

    vim.api.nvim_create_user_command("Note", file_note, {
        nargs = 1,
        range = true,
        complete = complete_notes,
        desc = "File the current draft (or a range) into a scratch note",
    })
end

return M

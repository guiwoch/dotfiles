return {
    "neovim/nvim-lspconfig",
    -- Roslyn (and some other servers) send hover markdown with HTML entities
    -- and backslash-escaped punctuation: "the&nbsp;NetworkStream&nbsp;and" and
    -- "zero \\(0\\)". Neovim doesn't decode either, so the float shows run-on
    -- words and stray backslashes. Clean the lines outside fenced code blocks.
    init = function()
        local entities = {
            ["&nbsp;"] = " ",
            ["&amp;"] = "&",
            ["&lt;"] = "<",
            ["&gt;"] = ">",
            ["&quot;"] = '"',
            ["&#39;"] = "'",
        }

        local open_floating_preview = vim.lsp.util.open_floating_preview
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
            if syntax == "markdown" and type(contents) == "table" then
                local in_code_block = false
                contents = vim.tbl_map(function(line)
                    if line:match("^%s*```") then
                        in_code_block = not in_code_block
                        return line
                    elseif in_code_block then
                        return line
                    end
                    line = line:gsub("&%a+;", entities):gsub("&#%d+;", entities)
                    -- Drop escapes before ASCII punctuation (CommonMark rule).
                    return (line:gsub("\\(%p)", "%1"))
                end, contents)
            end
            return open_floating_preview(contents, syntax, opts, ...)
        end
    end,
    opts = {
        -- Don't let servers insert the full call signature as snippet
        -- placeholders. blink's auto_brackets still adds "()" and puts the
        -- cursor inside, so you can just type the arguments.
        servers = {
            ["*"] = {
                capabilities = {
                    textDocument = {
                        completion = {
                            completionItem = {
                                snippetSupport = false,
                            },
                        },
                    },
                },
            },
        },
        inlay_hints = {
            enabled = false,
        },
        document_highlight = {
            enabled = false,
        },
        -- servers = {
        --     gopls = {
        --         root_dir = function(fname)
        --             -- Check if this is a fugitive buffer
        --             if type(fname) == "string" and fname:match("^fugitive://") then
        --                 return nil
        --             end
        --
        --             -- Use default root detection
        --             local util = require("lspconfig.util")
        --             return util.root_pattern("go.mod", ".git")(fname)
        --         end,
        --     },
        -- },
    },
}

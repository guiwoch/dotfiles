return {
    "folke/trouble.nvim",
    opts = {
        keys = {
            -- Jump to the item in the source buffer and apply its quickfix
            -- right away, instead of opening the code-action menu there.
            a = {
                action = function(view, ctx)
                    if not ctx.item then
                        return
                    end
                    view:jump(ctx.item)
                    require("gw.lspfix").fix()
                end,
                desc = "Apply quickfix",
            },
        },
    },
}

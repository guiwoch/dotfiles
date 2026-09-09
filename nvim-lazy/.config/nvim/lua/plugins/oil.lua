return {
    "stevearc/oil.nvim",
    opts = {
        default_file_explorer = false,
        view_options = {
            show_hidden = true,
        },
        skip_confirm_for_simple_edits = true,
        delete_to_trash = true,
    },
    dependencies = {
        { "nvim-mini/mini.icons", opts = {} },
    },
    lazy = false,
}

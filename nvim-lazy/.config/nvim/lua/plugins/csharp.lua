return {
    -- Disable omnisharp provided by the dotnet extra, and lspconfig's roslyn_ls
    -- (mason-lspconfig auto-enables it since roslyn-language-server is installed,
    -- which duplicates the client started by roslyn.nvim below)
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                omnisharp = { enabled = false },
                roslyn_ls = { enabled = false },
            },
        },
    },

    -- Roslyn LSP (same server as VS Code C# extension)
    {
        "seblj/roslyn.nvim",
        ft = "cs",
        opts = {
            config = {
                settings = {
                    ["csharp|navigation"] = {
                        dotnet_navigate_to_decompiled_sources = true,
                        dotnet_navigate_to_source_link_and_embedded_sources = true,
                    },
                    ["csharp|background_analysis"] = {
                        dotnet_analyzer_diagnostics_scope = "fullSolution",
                        dotnet_compiler_diagnostics_scope = "fullSolution",
                    },
                },
            },
        },
    },
}

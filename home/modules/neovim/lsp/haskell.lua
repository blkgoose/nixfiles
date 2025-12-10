return {
    cmd = { "haskell-language-server", "--lsp" },
    root_markers = {
        "hie.yaml",
        "stack.yaml",
        "cabal.project",
        "*.cabal",
    },
    filetypes = {
        "haskell",
    },
    settings = {
        haskell = {
            formattingProvider = "ormolu",
        },
    },
}

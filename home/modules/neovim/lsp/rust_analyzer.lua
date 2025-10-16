return {
    cmd = { "rust-analyzer" },
    filetypes = {
        "rust",
    },
    settings = {
        ["rust-analyzer"] = {
            rust = {
                analyzerTargetDir = false,
            },
            assist = {
                importEnforceGranularity = true,
                importPrefix = "crate",
            },
            cargo = {
                features = "all",
            },
            check = {
                features = "all",
                command = "check",
            },
            inlayHints = {
                lifetimeElisionHints = {
                    enable = true,
                    useParameterNames = true,
                },
            },
            numThreads = 4,
        },
    },
    root_markers = {
        "Cargo.toml",
    },
}

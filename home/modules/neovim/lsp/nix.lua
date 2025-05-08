return {
    name = "nix",
    cmd = { "nil" },
    root_markers = {
        "flake.nix",
    },
    filetypes = {
        "nix",
    },
    settings = {
        ["nil"] = {
            formatting = {
                command = { "nixfmt" },
            },
        },
    },
}

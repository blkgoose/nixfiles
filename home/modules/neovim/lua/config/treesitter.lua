require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash",
        "css",
        "dockerfile",
        "elixir",
        "elm",
        "html",
        "javascript",
        "json",
        "markdown",
        "python",
        "rust",
        "lua",
        "toml",
        "typescript",
        "vim",
    },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<c-s>",
            node_incremental = "<c-s>",
            -- scope_incremental = "<c-s>",
            node_decremental = "<c-S>",
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<c-[>"] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>A"] = "@parameter.inner",
            },
        },
    },
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "github/copilot.vim" },

    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            local snacks = require("snacks")

            snacks.setup({
                bigfile = { enabled = true },
                notifier = { enabled = true },
                quickfile = { enabled = true },
                statuscolumn = { enabled = false },
                words = { enabled = true },
                picker = {
                    enabled = true,
                    win = {
                        input = {
                            keys = {
                                ["<c-j>"] = { "list_down", mode = { "i", "n" } },
                                ["<c-k>"] = { "list_up", mode = { "i", "n" } },
                            },
                        },
                    },
                },
            })

            -- Keymaps
            keymap("<leader>fw", function() snacks.picker.grep() end)
            keymap("<leader>fW", function() snacks.picker.grep_word() end)
            keymap("<leader>of", function() snacks.picker.files() end)
            keymap("<leader>ob", function() snacks.picker.buffers() end)
            keymap("<c-h>", function() snacks.picker.resume() end)

            -- LSP keymaps
            keymap("gi", function() snacks.picker.lsp_implementations() end)
            keymap("gd", function() snacks.picker.lsp_definitions() end)
            keymap("gr", function() snacks.picker.lsp_references() end)
            keymap("gt", function() snacks.picker.lsp_type_definitions() end)
        end,
    },

    {
        "luukvbaal/statuscol.nvim",
        lazy = false,
        config = function()
            local builtin = require("statuscol.builtin")
            require("statuscol").setup({
                relculright = true,
                segments = {
                    { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
                    { text = { " %s" },                 click = "v:lua.ScSa" },
                    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = "BufReadPost",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash",
                    "css",
                    "diff",
                    "dockerfile",
                    "elixir",
                    "elm",
                    "fish",
                    "gitcommit",
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
            })
        end,
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<C-f>", ":Neotree toggle<CR>" },
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                filesystem = {
                    follow_current_file = true,
                    filtered_items = {
                        visible = true,
                    },
                },
                buffer = {
                    follow_current_file = true,
                },
            })
        end,
    },

    { "tpope/vim-commentary" },

    {
        "tpope/vim-fugitive",
        keys = {
            { "<leader>b",  ":Git blame<CR>" },
            { "<leader>gm", "/<<<<<<<\\|=======\\|>>>>>>><CR>" },
            { "<leader>gs", ":Gvdiffsplit<CR>" },
        },
    },

    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        opts = {
            numhl = true,
        },
    },

    { "mechatroner/rainbow_csv" },
    { "dag/vim-fish" },


    {
        "j-hui/fidget.nvim",
        tag = "legacy",
        event = "BufReadPre",
        opts = { window = { relative = "editor" } },
    },

    {
        "hrsh7th/nvim-cmp",
        event = "BufReadPost",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/vim-vsnip",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                mapping = {
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-e>"] = cmp.mapping.close(),
                    ["<cr>"] = cmp.mapping.confirm({ select = true }),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "vsnip" },
                    { name = "path" },
                    { name = "buffer",  keyword_length = 2, max_item_count = 8 },
                },
                formatting = {
                    fields = { "abbr", "kind" },
                    max_width = 0,
                    format = function(_, vim_item)
                        local function trim(text)
                            local max = 40
                            if text and #text > max then
                                text = text:sub(1, max) .. "..."
                            end
                            return text
                        end

                        vim_item.menu = ""
                        vim_item.abbr = trim(vim_item.abbr)
                        return vim_item
                    end,
                },
            })
        end,
    },

    {
        "folke/trouble.nvim",
        event = "BufReadPost",
        opts = { position = "bottom", height = 10 },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>d", ":lua require('trouble').toggle('workspace_diagnostics')<cr>" },
        },
    },

    {
        "arnamak/stay-centered.nvim",
        config = function()
            require("stay-centered")
        end,
    },
})

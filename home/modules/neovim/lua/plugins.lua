local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "danielefongo/recode.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
  },

  { "github/copilot.vim" },

  {
    "danielefongo/microscope",
    dependencies = {
      { "danielefongo/microscope-files", dev = false },
      "danielefongo/microscope-buffers",
      "danielefongo/microscope-code",
    },
    dev = false,
    config = function()
      require("config.microscope")
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
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { " %s" }, click = "v:lua.ScSa" },
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
      { "<leader>b", ":Git blame<CR>" },
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
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "ray-x/lsp_signature.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
    },
    keys = {
      { "<leader>c", ":lua vim.lsp.buf.code_action()<cr>" },
      { "<leader>h", ":lua vim.lsp.buf.signature_help()<cr>" },
      { "<leader>R", ":lua vim.lsp.buf.rename()<cr>" },
      { "<space>k", ":lua vim.diagnostic.goto_prev({ wrap = false })<cr>" },
      { "<space>j", ":lua vim.diagnostic.goto_next({ wrap = false })<cr>" },
    },
    config = function()
      local lsp = require("lspconfig")
      local cmp = require("cmp_nvim_lsp")
      local signature = require("lsp_signature")

      local mason = require("mason")
      local mason_lsp_config = require("mason-lspconfig")

      local flags = { debounce_text_changes = 150 }
      local capabilities = cmp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local function cmd_path(server)
        return fn.glob(fn.stdpath("data") .. "/lsp/bin/" .. server)
      end

      local function on_attach(client, bufnr)
        signature.on_attach({ bind = true }, bufnr)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true)
          end
        end,
      })

      local lsps = {
        bashls = {},
        cssls = {},
        dockerls = {},
        elixirls = {
          -- cmd = { cmd_path("elixir-ls") },
          settings = {
            elixirLS = {
              fetchDeps = false,
              mixEnv = "dev",
            },
          },
        },
        elmls = {},
        html = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              format = { enable = false },
            },
          },
        },
        marksman = {},
        pylsp = {},
        taplo = {},
        nil_ls = {},
      }

      local local_lsps = {
        rust_analyzer = {
          cmd = { "rust-analyzer" },
        },
        hls = {
          cmd = { "haskell-language-server-wrapper", "--lsp" },
        },
      }

      mason.setup({ install_root_dir = fn.stdpath("data") .. "/lsp/" })

      mason_lsp_config.setup({
        ensure_installed = vim.tbl_keys(lsps),
      })

      -- ignore server error for rust-analyzer
      for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
        local default_diagnostic_handler = vim.lsp.handlers[method]
        vim.lsp.handlers[method] = function(err, result, context, config)
          if err ~= nil and err.code == -32802 then
            return
          end
          return default_diagnostic_handler(err, result, context, config)
        end
      end

      for lsp_name, config in pairs(vim.tbl_deep_extend("force", lsps, local_lsps)) do
        lsp[lsp_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
          flags = flags,
          cmd = config.cmd,
          settings = config.settings or {},
        })
      end
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-null-ls.nvim",
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    config = function()
      local mason = require("mason")
      local null_ls = require("null-ls")
      local mason_null_ls = require("mason-null-ls")

      local null_sources = {
        shfmt = null_ls.builtins.formatting.shfmt, -- bash / sh
        mix = null_ls.builtins.formatting.mix, -- elixir
        elm_format = null_ls.builtins.formatting.elm_format, -- elm
        prettier = null_ls.builtins.formatting.prettier, -- html stuff
        stylua = null_ls.builtins.formatting.stylua.with({
          extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        }), -- lua
        markdownlint = null_ls.builtins.formatting.markdownlint, -- markdown
        black = null_ls.builtins.formatting.black, -- python
        taplo = null_ls.builtins.formatting.taplo, -- toml
        eslint = null_ls.builtins.formatting.eslint, -- ts (js)
        nixfmt = null_ls.builtins.formatting.nixfmt, -- nix
        fourmolu = null_ls.builtins.formatting.fourmolu, -- haskell
      }

      local local_sources = {
        rustfmt = null_ls.builtins.formatting.rustfmt, -- rust
      }

      mason.setup({ install_root_dir = fn.stdpath("data") .. "/lsp/" })

      null_ls.setup({
        sources = vim.tbl_values(vim.tbl_deep_extend("force", null_sources, local_sources)),
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  filter = function()
                    return client.name == "null-ls"
                  end,
                })
              end,
            })
          end
        end,
      })

      mason_null_ls.setup({
        ensure_installed = vim.tbl_keys(null_sources),
      })
    end,
  },

  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    event = "BufReadPre",
    opts = { window = { relative = "editor" } },
    dependencies = { "neovim/nvim-lspconfig" },
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
          { name = "buffer", keyword_length = 2, max_item_count = 8 },
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
}, {
  dev = { path = "~/proj/pers/lua/" },
})

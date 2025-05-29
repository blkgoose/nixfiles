{ nixvim, pkgs, ... }: {
  imports = [ nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;

    defaultEditor = true;
    vimdiffAlias = true;
    vimAlias = true;
    viAlias = true;

    clipboard.register = "unnamed,unnamedplus";

    colorschemes.gruvbox.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<C-f>";
        action = "<cmd>:lua MiniFiles.open()<CR>";
      }
      {
        mode = "n";
        key = "<leader>fw";
        action = "<cmd>:lua MiniPick.builtin.grep_live()<CR>";
      }
      {
        mode = "n";
        key = "<leader>of";
        action = "<cmd>:lua MiniPick.builtin.files()<CR>";
      }
      {
        mode = "n";
        key = "<F1>";
        action = "<cmd>:noh<CR>";
      }
      {
        mode = "n";
        key = "<leader>h";
        action = "<cmd>:lua vim.lsp.buf.signature_help()<CR>";
      }
      {
        mode = "n";
        key = "<leader>R";
        action = "<cmd>:lua vim.lsp.buf.rename()<CR>";
      }
      {
        mode = "n";
        key = "<space>j";
        action = "<cmd>:lua vim.diagnostic.goto_next()<CR>";
      }
      {
        mode = "n";
        key = "<space>k";
        action = "<cmd>:lua vim.diagnostic.goto_prev()<CR>";
      }
      {
        mode = "n";
        key = "<leader>cf";
        action = "<cmd>:lua vim.lsp.buf.format({async = true})<CR>";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd>:Git blame<CR>";
      }
      {
        mode = "n";
        key = "<leader>gm";
        action = "<cmd>/<<<<<<<\\|=======\\|>>>>>>><CR>";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>:Gvdiffsplit<CR>";
      }
       {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>lua vim.lsp.buf.references()<CR>";
    }
    {
      mode = "n";
      key = "gi";
      action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
    }
    {
      mode = "n";
      key = "gt";
      action = "<cmd>lua vim.lsp.buf.type_definition()<CR>";
    }
    ];

    lsp = {
      inlayHints.enable = true;

      servers = {
        rust_analyzer = {
          settings = {
            cmd = [ "rust-analyzer" ];
            filetypes = [ "rust" ];
            root_markers = [ "Cargo.toml" ];
          };
          enable = true;
        };
        nil_ls = {
          settings = {
            name = "nix";
            cmd = [ "${pkgs.nil}/bin/nil" ];
            root_markers = [ "flake.nix" ];
            filetypes = [ "nix" ];
            settings."nil".formatting.command = "${pkgs.nixfmt}/bin/nixfmt";
          };
          enable = true;
        };
        lua_ls = {
          settings = {
            filetypes = [ "lua" ];
            cmd = [ "${pkgs.lua-language-server}/bin/lua-language-server" ];
            root_markers = [ ".luarc.json" ".luarc.jsonc" ".stylua.toml" ];
          };
          enable = true;
        };
        biome = {
          settings = {
            filetypes = [
              "css"
              "graphql"
              "javascript"
              "javascriptreact"
              "json"
              "jsonc"
              "svelte"
              "typescript"
              "typescript.tsx"
              "typescriptreact"
            ];
            cmd = [ "${pkgs.biome}/bin/biome" "lsp-proxy" ];
            root_markers = [ "biome.json" "biome.jsonc" ];
          };
          enable = true;
        };
        elixirls = {
          settings = {
            cmd = [ "${pkgs.next-ls}/bin/next-ls" ];
            filetypes = [ "elixir" "eelixir" "heex" ];
            root_markers = [ "mix.lock" ];
          };
          enable = true;
        };
        elmls = {
          settings = {
            cmd = [
              "${pkgs.elmPackages.elm-language-server}/bin/elm-language-server"
            ];
            filetypes = [ "elm" ];
            root_markers = [ "elm.json" "elm-package.json" ];
          };
          enable = true;
        };
      };
    };

    plugins = {
      web-devicons.enable = true;

      trouble.enable = true;
      statuscol = { enable = true; };
      treesitter.enable = true;
      commentary.enable = true;
      fugitive.enable = true;
      gitsigns.enable = true;
      fidget.enable = true;

      mini = {
        enable = true;
        modules = {
          files.enable = true;
          pick.enable = true;
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      stay-centered-nvim
      copilot-vim
      CopilotChat-nvim
    ];

    extraConfigLua = ''
        -- Autoformat on save for supported buffers
        vim.api.nvim_create_autocmd("BufWritePre", {
          callback = function(args)
            vim.lsp.buf.format({ async = true })
          end,
        })

        -- highlight what has been copied
        vim.api.nvim_create_autocmd("TextYankPost", {
          callback = function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
          end,
        })

        -- Disable * behaviour
        vim.keymap.set("n", "*", function()
              local word = vim.fn.expand("<cword>")
              vim.fn.setreg("/", word)
              vim.opt.hlsearch = true
        end)
    '';

    opts = {
      number = true;
      wrap = false;
      showmatch = true;
      hidden = true;

      hlsearch = true;
      ignorecase = true;
      smartcase = true;
      incsearch = true;
      completeopt = "menu";
      autoindent = true;
      expandtab = true;
      shiftwidth = 4;
      smarttab = true;
      softtabstop = 4;
      relativenumber = true;
      cursorline = true;

      guicursor = "i:block";
      termguicolors = true;
      pumheight = 12;

      mouse = "";
    };
  };
}

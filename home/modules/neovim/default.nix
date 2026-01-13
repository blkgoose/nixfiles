{ pkgs, config, ... }: {
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.xdg.configHome}/nix/home/modules/neovim";

  programs.neovim = {
    package = pkgs.unstable.neovim-unwrapped;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    xclip
    lua-language-server
    nil
    taplo
    biome
    elixir-ls
    elmPackages.elm-language-server
    stylua
    tailwindcss
    python313Packages.python-lsp-server
    python313Packages.python-lsp-black
    haskellPackages.haskell-language-server
    ormolu
  ];
}

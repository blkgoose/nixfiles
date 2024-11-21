{ pkgs, config, ... }: {
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "/home/alessiobiancone/.config/nix/home/modules/neovim";

  programs.neovim = {
    package = pkgs.unstable.neovim-unwrapped;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}

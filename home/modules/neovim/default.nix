{ pkgs, config, lib, self, ... }:
let
  configHome = config.xdg.configHome + "/nix/";

  mkMutableLink = path:
    config.lib.file.mkOutOfStoreSymlink
    (configHome + lib.strings.removePrefix (toString self) (toString path));

in {
  xdg.configFile."nvim".source = mkMutableLink ./.;

  programs.neovim = {
    package = pkgs.unstable.neovim-unwrapped;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}

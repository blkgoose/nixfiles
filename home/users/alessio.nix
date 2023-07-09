{ pkgs, dots, ... }: {
  imports = [
    ../modules/alacritty.nix
    ../modules/core.nix
    ../modules/desktop.nix
    ../modules/dev.nix
    ../modules/git.nix
    ../modules/dwm.nix
    ../modules/neovim.nix
    ../modules/fish.nix
    ../modules/chromeapps.nix
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "23.05";
}

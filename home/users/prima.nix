{ ... }: {
  imports = [
    ../modules/alacritty.nix
    ../modules/core.nix
    ../modules/desktop.nix
    ../modules/dev.nix
    ../modules/git.nix
    ../modules/neovim
    ../modules/fish
    ../modules/prima
    ../modules/saint-peter.nix
    ../modules/chromeapps.nix
    ../modules/tmux.nix
    ../modules/xmonad
    ../modules/game.nix
  ];

  home.username = "alessiobiancone";
  home.homeDirectory = "/home/alessiobiancone";

  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}

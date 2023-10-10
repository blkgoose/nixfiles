{ ... }: {
  imports = [
    ../modules/alacritty.nix
    ../modules/core.nix
    ../modules/desktop.nix
    ../modules/dev.nix
    ../modules/git.nix
    ../modules/neovim
    ../modules/fish.nix
    ../modules/dunst.nix
    ../modules/saint-peter.nix
    ../modules/xmonad.nix
    ../modules/chromeapps.nix
    ../modules/aliases.nix
    ../modules/autorandr
    ../modules/battery_low_alert.nix
  ];

  home.file.".background-image".source = ./wallpaper;
  programs.home-manager.enable = true;
  home.stateVersion = "23.05";
}

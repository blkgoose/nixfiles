{ ... }: {
  imports = [
    ../modules/alacritty.nix
    ../modules/core.nix
    ../modules/desktop.nix
    ../modules/dev.nix
    ../modules/git.nix
    ../modules/neovim
    ../modules/fish
    ../modules/dunst.nix
    ../modules/saint-peter.nix
    ../modules/chromeapps.nix
    ../modules/aliases.nix
    ../modules/battery_low_alert.nix
    ../modules/eye_saver.nix
    ../modules/hyprland
    ../modules/prima.nix
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "23.11";
}

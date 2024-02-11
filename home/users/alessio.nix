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
    ../modules/xmonad.nix
    ../modules/chromeapps.nix
    ../modules/aliases.nix
    ../modules/autorandr.nix
    ../modules/battery_low_alert.nix
    ../modules/eye_saver.nix
    ../modules/hyprland.nix
    ../modules/waybar.nix
    ../modules/hyprpaper.nix
  ];

  home.file.".background-image".source = ./wallpaper;
  programs.home-manager.enable = true;
  home.stateVersion = "23.05";
}

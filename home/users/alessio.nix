{ ... }: {
  imports = [
    ../modules/alacritty.nix
    ../modules/3d-printing.nix
    ../modules/core.nix
    ../modules/desktop.nix
    ../modules/gdrive.nix
    ../modules/dev.nix
    ../modules/git.nix
    ../modules/neovim
    ../modules/fish
    ../modules/saint-peter.nix
    ../modules/chromeapps.nix
    ../modules/hyprland
    ../modules/niri
    ../modules/tmux
  ];

  module.dev.enable = true;

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}

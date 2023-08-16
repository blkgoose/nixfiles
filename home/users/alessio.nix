{ ... }: {
  imports = [
    ../modules/alacritty.nix
    ../modules/core.nix
    ../modules/desktop.nix
    ../modules/dev.nix
    ../modules/git.nix
    ../modules/neovim.nix
    ../modules/fish.nix
    ../modules/saint-peter.nix
    ../modules/xmonad.nix
    ../modules/chromeapps.nix
  ];

  home.file.".background-image".source = ./wallpaper;
  programs.home-manager.enable = true;
  home.stateVersion = "23.05";
}

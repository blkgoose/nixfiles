{ pkgs, ... }: {
  imports =
    [ ./xmonad.nix ./xmobar.nix ./picom.nix ./dunst.nix ./wallpaper.nix ];

  home.packages = with pkgs; [ autorandr pavucontrol ];
}

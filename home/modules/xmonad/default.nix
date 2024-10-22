{ pkgs, ... }: {
  imports = [ ./xmonad.nix ./xmobar.nix ./picom.nix ];

  home.packages = with pkgs; [ feh imagemagick autorandr pavucontrol ];

  home.file.".background-image" = {
    source = ./wallpaper;
    onChange = "${pkgs.feh}/bin/feh --bg-fill ~/.background-image";
  };
}

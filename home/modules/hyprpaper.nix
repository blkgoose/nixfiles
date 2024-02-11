{ pkgs, ... }:
let
  paper-conf = pkgs.writeText "hyprpaper.conf" ''
    ipc = off

    preload = ${../users/wallpaper}
    wallpaper = , ${../users/wallpaper}
  '';
in {
  home.file.".config/hypr/hyprpaper.conf".source = paper-conf;

}

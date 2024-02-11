{ pkgs, ... }:
let
  paper-conf = pkgs.writeText "hyprpaper.conf" ''
    ipc = off

    preload = ${./wallpaper}
    wallpaper = , ${./wallpaper}
  '';
in {
  home.file.".config/hypr/hyprpaper.conf".source = paper-conf;

}

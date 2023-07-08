{ pkgs, dots, ... }:
{
  home.packages = with pkgs; [
    dunst
    feh
    picom
  ];

  xdg.configFile = {
    "dunst/dunstrc".source = "${dots}/dunst/dunstrc";
    "picom/picom.conf".source = "${dots}/picom/picom.conf";
  };

  services.dunst.enable = true;
}

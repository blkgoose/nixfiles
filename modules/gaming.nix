{ pkgs, ... }: {
  programs.steam.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "*";

  services.flatpak = {
    enable = true;
    packages = [ "com.valvesoftware.SteamLink" ];
  };
}

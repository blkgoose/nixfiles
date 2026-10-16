{ lib, dms, ... }: {
  imports = [
    dms.homeModules.dank-material-shell
    ../dms-island-fixes
    ./dms.nix
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      target = "niri.service";
    };
    islandFixes.enable = true;
  };

  xdg.dataFile."wallpapers/wallpaper".source = lib.mkDefault ../hyprland/wallpaper;
}

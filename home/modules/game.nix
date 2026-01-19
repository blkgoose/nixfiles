{ pkgs, nix-flatpak, ... }: {
  imports = [ nix-flatpak.homeManagerModules.nix-flatpak ];

  home.packages = with pkgs; [
    (nixGL lutris)
    (alias "steamlink" "${
        (nixGL pkgs.flatpak)
      }/bin/flatpak --user run com.valvesoftware.SteamLink")
  ];

  services.flatpak = {
    enable = true;
    packages = [ "com.valvesoftware.SteamLink" ];
  };
}

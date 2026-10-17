{ pkgs, nix-flatpak, ... }: {
  imports = [ nix-flatpak.homeManagerModules.nix-flatpak ];

  home.packages = with pkgs; [
    lutris
    (alias "steamlink" "${pkgs.flatpak}/bin/flatpak --user run com.valvesoftware.SteamLink")
  ];

  services.flatpak = {
    enable = true;
    packages = [ "com.valvesoftware.SteamLink" ];
  };
}

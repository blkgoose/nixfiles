{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    gimp
    (alias "orca-slicer" "${(nixGL unstable.orca-slicer)}/bin/orca-slicer")
    zoom
    (alias "chrome" "${(nixGL google-chrome)}/bin/google-chrome-stable")
    (alias "jellyfin-desktop" "${(nixGL jellyfin-desktop)}/bin/jellyfin-desktop")
    pwvucontrol
    htop
    vial
  ];

  services.keynav = {
    enable = true;
    # extraConfig = {
    #   "alt+space" = "doubleclick";
    #   "alt+k" = "click 4";
    #   "alt+j" = "click 5";
    # };
  };

  services.kdeconnect.enable = true;

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

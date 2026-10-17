{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    gimp
    (alias "orca-slicer" "${unstable.orca-slicer}/bin/orca-slicer")
    zoom
    google-chrome
    (alias "chrome" "${google-chrome}/bin/google-chrome-stable")
    (alias "jellyfin-desktop" "${jellyfin-desktop}/bin/jellyfin-desktop")
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

{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    gimp
    zoom
    google-chrome
    (alias "chrome" "${google-chrome}/bin/google-chrome-stable")
    (appAlias "jellyfin-desktop" jellyfin-desktop)
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

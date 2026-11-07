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

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

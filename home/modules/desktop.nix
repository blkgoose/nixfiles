{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    gimp
    zoom
    google-chrome
    (alias "chrome" "${google-chrome}/bin/google-chrome-stable")
    (appAlias "jellyfin" jellyfin-desktop { })
    pwvucontrol
    htop
    vial
    (appAlias "discord" vesktop {
      params = "--enable-features=WebRTCPipeWireCapturer --ozone-platform-hint=auto";
      copy = discord;
    })
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

{ pkgs, ... }: {
  home.packages = with pkgs; [ spotify feh gimp google-chrome discord ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  services.wlsunset = {
    enable = true;
    latitude = "42.50";
    longitude = "12.50";
  };
}

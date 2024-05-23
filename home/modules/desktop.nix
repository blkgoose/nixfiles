{ pkgs, ... }: {
  home.packages = with pkgs; [ spotify feh gimp google-chrome discord ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  home.pointerCursor = {
    name = "Bibata-Modern.Classic";
    package = pkgs.bibata-cursors;
    size = 20;
  };

  services.wlsunset = {
    enable = true;
    latitude = "42.50";
    longitude = "12.50";
  };
}

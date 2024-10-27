{ ... }: {
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./hyprpaper.nix
    ./swayidle.nix
    ./swaync.nix
    ./wofi.nix
  ];

  services.wlsunset = {
    enable = true;
    latitude = "42.50";
    longitude = "12.50";
  };
}

{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    xwayland.enable = true;
  };
  programs.waybar = { enable = true; };
  environment.systemPackages = with pkgs; [ wofi hyprpaper ];

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
  };
}

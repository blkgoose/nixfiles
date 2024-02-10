{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.waybar = { enable = true; };
  environment.systemPackages = with pkgs; [ wofi xwaylandvideobridge ];

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
  };
}

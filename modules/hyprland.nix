{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    xwayland.enable = true;
  };
  programs.waybar = { enable = true; };
  environment.systemPackages = with pkgs; [ hyprpaper wl-clipboard ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
  };

  xdg.portal.enable = true;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
}

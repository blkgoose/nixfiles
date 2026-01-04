{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    xwayland.enable = true;
  };
  environment.systemPackages = with pkgs; [ hyprpaper wl-clipboard ];

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;

  xdg.portal.enable = true;

  fonts.packages = with pkgs; [ fira-code ];

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
}

{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ wl-clipboard ];

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;

  xdg.portal.enable = true;

  fonts.packages = with pkgs; [ fira-code ];
}

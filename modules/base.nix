{ pkgs, ... }: {
  boot.loader = {
    efi = { canTouchEfiVariables = false; };
    systemd-boot.enable = true;
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [ htop ];

  programs.steam.enable = true;

  fonts.packages = with pkgs; [
    font-awesome
    (nerdfonts.override { fonts = [ "Hasklig" ]; })
  ];
}

{ pkgs, ... }: {
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    timeout = null;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [ htop ];

  programs.steam.enable = true;

  fonts.packages = with pkgs; [ font-awesome ];
}

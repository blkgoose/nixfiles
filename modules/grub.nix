{ pkgs, ... }: {
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
    };
    timeout = 30;
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [ htop ];

  fonts.packages = with pkgs; [ font-awesome ];
}

{ pkgs, ... }:
{
  boot.loader = {
    efi = {
      canTouchEfiVariables = false;
    };
    systemd-boot.enable = true;
  };

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  # fonts.fonts = with pkgs; [
  #   font-awesome
  #   (nerdfonts.override { fonts = [ "Hasklig" ]; })
  # ];
}

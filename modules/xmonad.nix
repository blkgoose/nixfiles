{ lib, pkgs, ... }: {
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = true;
        greeters.enso = {
          enable = true;
          blur = true;
        };
      };
    };
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    libinput.enable = true;
    xkbOptions =
      lib.strings.concatStringsSep "," [ "compose:ralt" "caps:none" ];
  };

  environment.systemPackages = with pkgs; [
    haskellPackages.xmobar
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
  ];

  services.dbus.enable = true;
}

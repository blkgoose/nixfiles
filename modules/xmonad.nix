{ pkgs, ... }: {
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
  };

  environment.systemPackages = with pkgs; [
    haskellPackages.xmobar
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
  ];

  services.dbus.enable = true;
}

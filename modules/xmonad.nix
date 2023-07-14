{ ... }: {
  services.xserver = {
    enable = true;
    displayManager = { lightdm.enable = true; };
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = hpkgs: [ hpkgs.xmobar ];
    };
    libinput.enable = true;
  };

  services.dbus.enable = true;
}

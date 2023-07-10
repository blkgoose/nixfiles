{ ... }: {
  services.xserver = {
    enable = true;
    displayManager = { lightdm.enable = true; };
    windowManager.xmonad.enable = true;
    libinput.enable = true;
  };

  services.dbus.enable = true;
}

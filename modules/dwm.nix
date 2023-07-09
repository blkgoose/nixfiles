{ ... }: {
  services.xserver = {
    enable = true;
    displayManager = { lightdm.enable = true; };
    windowManager.dwm.enable = true;
    libinput.enable = true;
  };

  services.dbus.enable = true;
}

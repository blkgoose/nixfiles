{ ... }: {
  boot.loader = {
    efi = { canTouchEfiVariables = false; };
    systemd-boot.enable = true;
  };
}

{ secret_dots, ... }: {
  imports = [ ./network-manager.nix ];

  networking.networkmanager.enable = true;
}

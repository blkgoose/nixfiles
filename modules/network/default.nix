{ ... }: {
  imports = [ ./network-manager.nix ];

  networking.networkmanager.enable = true;
}

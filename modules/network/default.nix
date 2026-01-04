{ chaotic, ... }: {
  imports = [ ./network-manager.nix chaotic.nixosModules.default ];

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  chaotic.nordvpn.enable = true;
}

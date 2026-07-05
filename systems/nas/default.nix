{ pkgs, nixos-hardware, ... }: {
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-cpu-intel

    ../../modules/base.nix
    ../../modules/systemd-boot.nix
    ../../modules/dashboard-common.nix
    ../../modules/home-assistant
    ../../modules/media-server
  ];

  environment.systemPackages = with pkgs; [ btrfs-progs ];

  programs.fish.enable = true;

  users.users.root.shell = pkgs.fish;

  networking.hostName = "nas";

  networking.interfaces.enp2s0.ipv4.addresses = [{
    address = "192.168.1.101";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      ipv6 = true;
      "fixed-cidr-v6" = "fd00::/80";
    };
  };
}

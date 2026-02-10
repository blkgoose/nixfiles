{ pkgs, nixos-hardware, ... }: {
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-cpu-intel

    ../../modules/base.nix
    ../../modules/virtualization.nix
    ../../modules/systemd-boot.nix
  ];

  users.users.alessio-biancone = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  networking = {
    hostName = "nas";
    interfaces.enp1s0.ipv4.addresses = [{
      address = "192.168.1.101";
      prefixLength = 24;
    }];
    firewall.allowedTCPPorts = [ 22 ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
}

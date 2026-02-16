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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  virtualisation.docker.enable = true;
}

{ nixos-hardware, ... }: {
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.common-cpu-amd

    ../../modules/base.nix
    ../../modules/grub.nix
    ../../modules/hyprland.nix
    ../../modules/network
    ../../modules/sound.nix
    ../../modules/virtualization.nix
    ../../modules/entertainment.nix

    ../../modules/users
    ../../modules/users/alessio.nix
  ];

  networking.hostName = "toaster";

  services.hardware.bolt.enable = true;

  system.stateVersion = "25.11";
}

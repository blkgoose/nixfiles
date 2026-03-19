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

  # temporary
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.openssh.enable = true;

  services.hardware.bolt.enable = true;

  system.stateVersion = "25.11";
}

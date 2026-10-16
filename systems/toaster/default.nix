{ config, nixos-hardware, ... }: {
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
    ../../modules/transcriber

    ../../modules/users
    ../../modules/users/alessio.nix
  ];

  networking.hostName = "toaster";
  networking.networkmanager.settings.connection."ethernet.wake-on-lan" = "magic";

  boot.extraModulePackages = [ config.boot.kernelPackages.r8168 ];
  boot.blacklistedKernelModules = [ "r8169" ];
  boot.extraModprobeConfig = "options r8168 s5wol=1";

  # placed here or it would apply to the work laptop as well
  home-manager.users.alessio.imports = [ ../../home/modules/claude.nix ];

  # temporary
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.openssh.enable = true;

  services.tailscale.enable = true;

  services.hardware.bolt.enable = true;

  system.stateVersion = "26.05";
}

{ config, pkgs, nixos-hardware, home-manager, ... }: {
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-gpu-intel
    nixos-hardware.nixosModules.common-pc-laptop

    ../../modules/base.nix
    ../../modules/xmonad.nix
    ../../modules/network
    ../../modules/sound.nix
    ../../modules/virtualization.nix
    ../../modules/orca-slicer.nix

    ../../modules/users
    ../../modules/users/alessio.nix

    ../../modules/prima
  ];

  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [ git vim wget ];

  networking.hostName = "bjorn";

  hardware.opengl = {
    driSupport.enable = true;
    extraPackages = with pkgs; [ vaapiIntel vaapiVdpau intel-compute-runtime ];
  };

  services.hardware.bolt.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];
  services.logind.lidSwitch = "ignore";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05";
}
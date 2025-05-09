{ pkgs, nixos-hardware, ... }: {
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.common-cpu-amd

    ../../modules/grub.nix
    ../../modules/hyprland.nix
    ../../modules/network
    ../../modules/sound.nix
    ../../modules/virtualization.nix

    ../../modules/users
    ../../modules/users/alessio.nix
  ];

  programs.command-not-found.enable = false;

  environment.systemPackages = with pkgs; [ git vim wget ];

  networking.hostName = "toaster";

  services.hardware.bolt.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15d";
  };

  system.stateVersion = "24.11";
}

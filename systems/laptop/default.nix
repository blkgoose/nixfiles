{ config, pkgs, home-manager, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/base.nix
    ../../modules/xmonad.nix
    ../../modules/network
    ../../modules/sound.nix
    ../../modules/users
    ../../modules/users/alessio.nix
  ];

  environment.systemPackages = with pkgs; [ git vim wget dmenu ];

  networking.hostName = "bjorn";

  hardware.opengl = {
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  services.hardware.bolt.enable = true;

  services.xserver.videoDrivers = [ "intel" ];
  services.logind.lidSwitch = "ignore";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05";
}

{ config, pkgs, home-manager, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/base.nix
    ../../modules/dwm.nix
    ../../modules/network.nix
    ../../modules/sound.nix
    ../../modules/users
    ../../modules/users/alessio.nix
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget

    dmenu
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05";
}

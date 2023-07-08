{ pkgs, ... }:
{
  users.users.alessio = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  home-manager.users.alessio.imports = [
    ../../home/users/alessio.nix
  ];
}

{ pkgs, ... }: {
  users.users.alessio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  home-manager.users.alessio.imports = [ ../../home/users/alessio.nix ];
}

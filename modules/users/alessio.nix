{ pkgs, ... }: {
  users.users.alessio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  environment.localBinInPath = true;
  home-manager.users.alessio = { imports = [ ../../home/users/alessio.nix ]; };
}

{ pkgs, ... }: {
  users.users.prima = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  environment.localBinInPath = true;
  home-manager.users.prima.imports = [ ../../home/users/prima.nix ];
}

{ pkgs, ... }: {
  imports = [ ../users/prima.nix ../modules/docker.nix ];
  # overrides
  programs.alacritty.package = pkgs.emptyDirectory; # installed by system

  home.packages = with pkgs; [ (nixGL alacritty) ];
}

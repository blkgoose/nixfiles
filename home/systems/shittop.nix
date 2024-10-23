{ pkgs, ... }: {
  imports = [ ../users/prima.nix ../modules/docker.nix ];
  programs.alacritty.package = with pkgs; nixGL alacritty;

}

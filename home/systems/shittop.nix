{ pkgs, ... }: {
  imports = [ ../users/prima.nix ../modules/docker.nix ];
  programs.alacritty.package = with pkgs; nixGL alacritty;

  xsession.numlock.enable = false;
  xsession.initExtra = ''
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option compose:ralt
  '';
}

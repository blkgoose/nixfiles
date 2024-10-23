{ pkgs, lib, ... }: {
  imports = [ ../users/prima.nix ];

  # overrides because ubuntu sucks
  programs.alacritty.package = with pkgs; nixGL alacritty;
  systemd.user.services."picom".Service.ExecStart = with pkgs;
    lib.mkForce "${(nixGL picom)}/bin/picom";

  xsession.enable = true;
  xsession.numlock.enable = false;
  xsession.initExtra = ''
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option compose:ralt
  '';
}

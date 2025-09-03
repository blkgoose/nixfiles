{ pkgs, lib, ... }: {
  imports = [ ../users/prima.nix ];

  # overrides because ubuntu sucks
  programs.alacritty.package = with pkgs; nixGL alacritty;
  systemd.user.services.picom.Service.ExecStart = with pkgs;
    lib.mkForce "${(nixGL picom)}/bin/picom";

  xsession.enable = true;

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [ nerd-fonts.hack nerd-fonts.roboto-mono docker (nixGL google-chrome) ];
}

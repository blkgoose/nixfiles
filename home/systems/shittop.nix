{ pkgs, lib, ... }: {
  imports = [ ../users/prima.nix ];

  # overrides because ubuntu sucks
  programs.alacritty.package = with pkgs; nixGL alacritty;
  systemd.user.services.picom.Service.ExecStart = with pkgs;
    lib.mkForce "${(nixGL picom)}/bin/picom";

  xsession.enable = true;

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [ docker (nixGL google-chrome) ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}

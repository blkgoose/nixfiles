{ pkgs, lib, ... }: {
  imports = [ ../users/prima.nix ];

  # overrides because ubuntu sucks
  programs.alacritty.package = with pkgs; nixGL alacritty;
  systemd.user.services.picom.Service.ExecStart = with pkgs;
    lib.mkForce "${(nixGL picom)}/bin/picom";

  xsession.enable = true;

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [ docker (nixGL google-chrome) nixos-rebuild ];

  systemd.user.sessionVariables = {
    CARGO_TARGET_DIR = "/media/data/cargo-target";
    RUSTC_WRAPPER = "sccache";
    SCCACHE_DIR = "/media/data/sccache";
    SCCACHE_CACHE_SIZE = "20G";
    CARGO_INCREMENTAL = "0";
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}

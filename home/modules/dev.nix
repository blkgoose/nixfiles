{ pkgs, ... }: {
  home.packages = with pkgs; [
    rustup
    nixfmt-classic
    pkg-config
    openssl
    fh
    (alias "nh" ''sudo "$(which "${pkgs.nh}/bin/nh")"'')
    gh
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

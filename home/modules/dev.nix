{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs_20
    rustup
    nixfmt-classic
    clang
    yarn
    unstable.bruno
    kubectl
    awscli2
    pkg-config
    openssl
    fh
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

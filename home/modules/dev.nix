{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs_20
    rustup
    nixfmt-classic
    clang
    yarn
    bruno
    kubectl
    awscli2
    pkg-config
    openssl
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

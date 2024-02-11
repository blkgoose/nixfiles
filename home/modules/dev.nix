{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs_20
    rustup
    nixfmt
    clang
    yarn
    insomnia
    kubectl
    pre-commit
    awscli2
    pkg-config
    openssl
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

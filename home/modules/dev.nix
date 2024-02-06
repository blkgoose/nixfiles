{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs_20
    rustup
    nixfmt
    clang
    yarn
    insomnia
    kubectl
    suite_py
    pre-commit
    awscli2
  ];

}

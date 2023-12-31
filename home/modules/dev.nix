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

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ms-vsliveshare.vsliveshare
      rust-lang.rust-analyzer
    ];
  };
}

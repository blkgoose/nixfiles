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
    gh
    vault
    (alias "gemini-cli"
      "${(gemini-cli)}/bin/gemini --model gemini-2.5-flash --yolo")
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

{ pkgs, ... }: {
  home.packages = with pkgs; [
    autojump
    autorandr
    bat
    file
    fzf
    gnumake
    jq
    killall
    ncdu
    ripgrep
    tldr
    tree
    unp
    unzip
  ];
}

{ pkgs, ... }: {
  home.packages = with pkgs; [
    autojump
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
    wakeonlan
    unstable.nix
    linuxKernel.packages.linux_zen.cpupower
    git-crypt
  ];
}

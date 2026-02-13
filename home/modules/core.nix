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
    unstable.nix
    linuxKernel.packages.linux_zen.cpupower
    git-crypt
    # wrapped to sudo by default
    (alias "system-manager"
      ''sudo "$(which ${system-manager}/bin/system-manager)"'')
  ];
}

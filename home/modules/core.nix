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
    # wrapped to sudo by default
    (alias "system-manager"
      ''sudo "$(which ${system-manager}/bin/system-manager)"'')
  ];
}

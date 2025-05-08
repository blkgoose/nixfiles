{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    gimp
    orca-slicer
    beekeeper-studio
    zoom
    (alias "chrome" "${(nixGL google-chrome)}/bin/google-chrome-stable")
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

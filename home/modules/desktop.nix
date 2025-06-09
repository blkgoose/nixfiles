{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    gimp
    (alias "orca-slicer" "${(nixGL orca-slicer)}/bin/orca-slicer")
    beekeeper-studio
    zoom
    (alias "chrome" "${(nixGL google-chrome)}/bin/google-chrome-stable")
    (alias "legcord" "${(nixGL legcord)}/bin/legcord")
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    gimp
    (alias "bambu-studio" "${(nixGL unstable.bambu-studio)}/bin/bambu-studio")
    beekeeper-studio
    zoom
    (alias "chrome" "${(nixGL google-chrome)}/bin/google-chrome-stable")
    (alias "discord" "${(nixGL legcord)}/bin/legcord")
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

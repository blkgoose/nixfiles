{ pkgs, ... }: {
  home.packages = with pkgs; [
    spotify
    feh
    gimp
    google-chrome
    discord
    orca-slicer
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

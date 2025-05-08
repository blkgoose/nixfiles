{ pkgs, ... }: {
  home.packages = with pkgs; [ spotify feh gimp orca-slicer ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

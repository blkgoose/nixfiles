{ pkgs, ... }: {
  home.packages = with pkgs; [ spotify gimp orca-slicer ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

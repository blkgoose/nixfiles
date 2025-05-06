{ pkgs, ... }: {
  home.packages = with pkgs; [ spotify feh gimp orca-slicer legcord ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

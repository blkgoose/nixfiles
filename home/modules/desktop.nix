{ pkgs, ... }: {
  home.packages = with pkgs; [ spotify feh gimp google-chrome ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

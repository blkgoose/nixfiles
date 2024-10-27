{ pkgs, ... }: {
  home.packages = with pkgs; [ spotify feh gimp google-chrome discord ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

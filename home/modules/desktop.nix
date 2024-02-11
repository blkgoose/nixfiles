{ pkgs, ... }: {
  home.packages = with pkgs; [ spotify feh gimp xclip google-chrome ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

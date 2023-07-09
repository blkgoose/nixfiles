{ pkgs, dots, ... }: {
  home.packages = with pkgs; [ alacritty ];

  # xdg.configFile."alacritty/alacritty.yml".source = "${dots}/alacritty";
}

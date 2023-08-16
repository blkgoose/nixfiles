{ dots, ... }: {
  home.file.".config/xmonad" = {
    source = "${dots}/xmonad";
    recursive = true;
  };
}

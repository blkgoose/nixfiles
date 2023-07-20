{ pkgs, dots, ... }: {
  home.packages = with pkgs; [
    discord
    google-chrome
    slack
    spotify
    telegram-desktop
    whatsapp-for-linux
    dunst
    feh
    picom
    gimp
    mesa-demos
    autorandr
  ];

  xdg.configFile."dunst/dunstrc".source = "${dots}/dunst/dunstrc";
  home.file.".config/xmonad" = {
    source = "${dots}/xmonad";
    recursive = true;
  };

  services.autorandr.enable = true;
  services.dunst.enable = true;
  services.picom = {
    enable = true;
    # backend = "glx";
    vSync = true;
    # fade = true;
    # inactiveOpacity = 0.8;

    # settings = {
    #   blur = {
    #     method = "dual_kawase";
    #     strength = 7.0;
    #     deviation = 1.0;
    #     kernel = "11x11gaussian";
    #   };
    #   blur-background = false;
    #   blur-background-frame = true;
    #   blur-background-fixed = true;

    #   blur-background-exclude = [ "class_g = 'Chrome'" "name = 'slop'" ];

    #   corner-radius = 10.0;
    # };
  };
}

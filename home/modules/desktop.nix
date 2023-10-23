{ pkgs, dots, ... }: {
  home.packages = with pkgs; [
    discord
    spotify
    feh
    gimp
    xclip
    autorandr
    google-chrome
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  services.redshift = {
    enable = true;
    provider = "manual";
    latitude = "45.4643";
    longitude = "9.1895";
    settings = {
      redshift = {
        brightness-day = 1;
        brightness-night = 0.6;
      };
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

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

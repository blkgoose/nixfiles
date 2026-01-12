{ ... }: {
  services.picom = {
    enable = true;
    settings = {
      backend = "glx";
      vsync = true;
      corner-radius = 20;
      round-borders = true;
    };
  };
}

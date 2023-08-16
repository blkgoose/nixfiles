{ ... }: {
  services.autorandr.enable = true;
  home.file = {
    ".config/autorandr/postswitch".source = ./postswitch;
    ".config/autorandr/predetect".source = ./predetect;
  };
}

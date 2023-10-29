{ pkgs, ... }: {
  services.autorandr.enable = true;

  programs.autorandr = {
    enable = true;

    hooks = {
      postswitch = {
        "change-background" =
          "${pkgs.feh}/bin/feh --bg-fill ~/.background-image";
      };

      predetect = {
        "ignore" =
          "${pkgs.xorg.xset}/bin/xset q | ${pkgs.gnugrep}/bin/grep 'Monitor is On' -q || exit 1";
      };
    };
  };
}

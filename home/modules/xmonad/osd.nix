{ pkgs, osd, ... }: {
  imports = [ osd.homeManagerModules.osd ];

  osd = {
    enable = true;
    settings = {
      "brightness" = {
        source = "file";
        path = "/sys/class/backlight/intel_backlight/brightness";
        max = 19393;
      };
      "volume" = {
        source = "poll";
        command = ''
          ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ |
          ${pkgs.coreutils}/bin/cut -d ':' -f2 |
          ${pkgs.findutils}/bin/xargs |
          ${pkgs.coreutils}/bin/tr -d '\n' |
          ${pkgs.coreutils}/bin/tr -d '.'
        '';
      };
      "volume:spotify" = {
        source = "poll";
        command = ''
          ${pkgs.wireplumber}/bin/wpctl get-volume $(
            ${pkgs.wireplumber}/bin/wpctl status |
            ${pkgs.gnugrep}/bin/grep 'Streams' -A 10 |
            ${pkgs.gnugrep}/bin/grep 'spotify' |
            ${pkgs.coreutils}/bin/cut -d'.' -f1
          ) |
          ${pkgs.coreutils}/bin/cut -d ':' -f2 |
          ${pkgs.findutils}/bin/xargs |
          ${pkgs.coreutils}/bin/tr -d '\n' |
          ${pkgs.coreutils}/bin/tr -d '.'
        '';
      };
    };
  };
}

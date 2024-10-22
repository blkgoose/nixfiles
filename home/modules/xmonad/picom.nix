{ pkgs, ... }: {
  home.packages = [ pkgs.picom ];

  xdg.configFile."picom/picom.conf" = {
    text = ''
      vsync = true;
      backend = "glx";
      corner-radius = 10;
      round-borders = 1;
    '';
    onChange = "${pkgs.systemd}/bin/systemctl --user restart picom";
  };

  systemd.user.services."picom" = {
    Unit.Description = "Runs picom correctly";
    Service.ExecStart = "${pkgs.picom}/bin/picom";
    Install.WantedBy = [ "graphical-session.target" ];

    Unit = {
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
  };

}

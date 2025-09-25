{ pkgs, ... }: {
  systemd.user.services.wallpaper = {
    Unit.Description = "Sets wallpaper";
    Service.ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${./wallpaper}";
    Install.WantedBy = [ "graphical-session.target" ];

    Unit = {
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
  };
}

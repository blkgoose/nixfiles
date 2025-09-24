{ pkgs, ... }: {
  systemd.user.services.wallpaper = {
    Unit.Description = "Sets wallpaper";
    Service.ExecStart = pkgs.writers.writeBash "wallpaper-setter" ''
      while true; do
          ${pkgs.feh}/bin/feh --bg-fill ${./wallpaper}
          sleep 5
      done
    '';
    Install.WantedBy = [ "graphical-session.target" ];

    Unit = {
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
  };
}

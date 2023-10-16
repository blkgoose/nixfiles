{ pkgs, ... }:
let
  eye_saver = pkgs.writers.writeBash "eye-saver" ''
    ${pkgs.dunst}/bin/dunstify \
        -a "Look out!" \
        -u low \
        -i windows95 \
        "Relax your eyes looking out the window"
  '';
in {
  systemd.user.services."eye_saver" = {
    Unit.Description = "Tells the user to look outside to save its eyes";
    Service.ExecStart = eye_saver;
  };

  systemd.user.timers."eye_saver" = {
    Unit.Description = "eye_saver timer";
    Timer = {
      Unit = "eye_saver.service";
      OnCalendar = "*:0/20:0";
      Persistent = true;
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}

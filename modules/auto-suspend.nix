{ pkgs, ... }:
let
  idleMinutes = 15;

  check = pkgs.writeShellScript "auto-suspend-check" ''
    export PATH=${
      pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.findutils
        pkgs.gawk
        pkgs.iproute2
        pkgs.systemd
      ]
    }
    stamp=/run/auto-suspend.stamp

    busy() {
      [ "$(ss -H -tn state established '( sport = :22 )' | wc -l)" -gt 0 ] && return 0
      awk '$1 < 0.5 { exit 1 }' /proc/loadavg && return 0
      [ -n "$(find /home/alessio/.claude/projects -name '*.jsonl' -mmin -5 -print -quit 2>/dev/null)" ] && return 0
      for s in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
        eval "$(loginctl show-session "$s" -p Type -p Class -p IdleHint -p State)"
        case "$Type:$Class:$IdleHint:$State" in
          wayland:user:no:active | x11:user:no:active) return 0 ;;
        esac
      done
      return 1
    }

    if busy; then
      touch "$stamp"
      exit 0
    fi

    [ -e "$stamp" ] || { touch "$stamp"; exit 0; }
    age=$(( $(date +%s) - $(stat -c %Y "$stamp") ))
    [ "$age" -ge ${toString (idleMinutes * 60)} ] || exit 0

    rm -f "$stamp"
    exec systemctl suspend
  '';
in
{
  systemd.services.auto-suspend = {
    description = "Suspend after a period without ssh, desktop or load activity";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = check;
    };
  };

  systemd.timers.auto-suspend = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
    };
  };
}

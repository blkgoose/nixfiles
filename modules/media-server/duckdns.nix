{ name, token }:
{ pkgs, ... }: {
  systemd.services.dns-update = {
    description = "updates dns record";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.curl}/bin/curl -k "https://www.duckdns.org/update?domains=${name}&token=${token}&ip="'';
    };
  };

  systemd.timers.dns-update = {
    description = "timer for dns update";
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
    };
    wantedBy = [ "timers.target" ];
  };
}

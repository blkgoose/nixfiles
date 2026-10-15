{ pkgs, ... }:
let
  fixJs = pkgs.writeText "jellyfin-subs-fix.js" (builtins.readFile ./jellyfin-subs-fix.js);
in
{
  # Jellyfin on port 8097 with a script injected into the web client, for the projector whose browser
  # shows every embedded-subtitle line twice (see jellyfin-subs-fix.js). Other clients keep using 8096.
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."jellyfin-projector" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8097;
        }
      ];
      locations."= /__fix.js".extraConfig = ''
        default_type application/javascript;
        add_header Cache-Control "no-store";
        alias ${fixJs};
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_set_header Accept-Encoding "";
          sub_filter_types text/html;
          sub_filter '</head>' '<script src="/__fix.js"></script></head>';
          sub_filter_once on;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8097 ];
}

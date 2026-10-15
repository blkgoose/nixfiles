{ pkgs, ... }:
let
  fixJs = pkgs.writeText "jellyfin-subs-fix.js" (builtins.readFile ./jellyfin-subs-fix.js);
  tvJs = pkgs.writeText "jellyfin-tv-nav.js" (builtins.readFile ./jellyfin-tv-nav.js);
in
{
  # Jellyfin on port 8097 with two scripts injected into the web client, for the projector's browser:
  # it shows every embedded-subtitle line twice (jellyfin-subs-fix.js) and its remote only moves a mouse
  # cursor (jellyfin-tv-nav.js). Other clients keep using 8096.
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
      locations."= /__tv.js".extraConfig = ''
        default_type application/javascript;
        add_header Cache-Control "no-store";
        alias ${tvJs};
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_set_header Accept-Encoding "";
          sub_filter_types text/html;
          sub_filter '</head>' '<script src="/__tv.js"></script><script src="/__fix.js"></script></head>';
          sub_filter_once on;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8097 ];
}

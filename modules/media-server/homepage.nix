{ ip }:
{ ... }: {
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    allowedHosts = "${ip}:8082,localhost,127.0.0.1";

    widgets = [
      {
        datetime = {
          format = {
            time = "short";
            date = "long";
          };
        };
      }
      {
        resources = {
          cpu = true;
          memory = true;
          uptime = true;
          disk = "/mnt/data";
        };
      }
    ];

    services = [
      {
        "Media" = [
          {
            "Jellyfin" = {
              icon = "jellyfin.png";
              href = "http://${ip}:8096";
            };
          }
          {
            "Jellyseerr" = {
              icon = "jellyseerr.png";
              href = "http://${ip}:5055";
            };
          }
        ];
      }
      {
        "Management" = [
          {
            "qBittorrent" = {
              icon = "qbittorrent.png";
              href = "http://${ip}:8080";
            };
          }
          {
            "Radarr" = {
              icon = "radarr.png";
              href = "http://${ip}:7878";
            };
          }
          {
            "Sonarr" = {
              icon = "sonarr.png";
              href = "http://${ip}:8989";
            };
          }
        ];
      }
    ];

    settings = {
      title = "N100 Media Home";
      # favicon = "https://jellyfin.org/images/logo.png";
      layout = {
        "Media" = {
          style = "columns";
          columns = 2;
        };
        "Management" = {
          style = "columns";
          columns = 1;
        };
      };
    };
  };
}

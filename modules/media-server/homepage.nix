{ ip }:
{ ... }: {
  services.homepage-dashboard = {
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
      layout = {
        "Media" = {
          style = "columns";
          columns = 1;
        };
        "Management" = {
          style = "columns";
          columns = 1;
        };
      };
    };
  };
}

{ pkgs, ... }: {
  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
    allowedUDPPorts = [ 5353 ];
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      volumes = [
        "/mnt/data/config/homeassistant:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = { TZ = "Europe/Rome"; };

      extraOptions = [ "--network=host" "--privileged" ];
    };

    matter-server = {
      image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
      extraOptions = [ "--network=host" ];
      volumes = [ "/mnt/data/config/matter:/data" "/run/dbus:/run/dbus:ro" ];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.homepage-dashboard = {
    services = [{
      "Home" = [{
        "Assistant" = {
          icon = "home-assistant.png";
          href = "http://192.168.1.101:8123";
        };
      }];
    }];

    settings = {
      layout = {
        "Home" = {
          style = "columns";
          columns = 3;
        };
      };
    };
  };
}

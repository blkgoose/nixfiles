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

  systemd.services.hacs = {
    description = "HACS";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ wget bash unzip git ];

    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/mnt/data/config/homeassistant";
      ExecStart = pkgs.writeShellScript "install-hacs" ''
        if [ ! -d "custom_components/hacs" ]; then
          echo "HACS not found. Installing..."
          ${pkgs.wget}/bin/wget -q -O - https://install.hacs.xyz | ${pkgs.bash}/bin/bash -
        else
          echo "HACS already installed."
        fi
      '';
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

{ pkgs, nixos-hardware, ... }: {
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-cpu-intel

    ../../modules/base.nix
    ../../modules/systemd-boot.nix
  ];

  environment.systemPackages = with pkgs; [ btrfs-progs lm_sensors ];

  users.users.alessio-biancone = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "video" "render" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  networking = {
    hostName = "nas";
    interfaces.enp1s0.ipv4.addresses = [{
      address = "192.168.1.101";
      prefixLength = 24;
    }];
    firewall.allowedTCPPorts = [ 22 80 443 8082 ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  virtualisation.docker.enable = true;

  environment.etc = {
    "arr/docker-compose.yml".source = ./docker-compose.yml;
    "arr/.env".source = pkgs.writeText "env" ''
      NORDVPN_USER=${pkgs.secret "nordvpn/username"}
      NORDVPN_PASS=${pkgs.secret "nordvpn/password"}
    '';
  };

  systemd.services.arr-stack = {
    description = "arr-stack";
    after = [ "network.target" "mnt-data.mount" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      cd /etc/arr
      ${pkgs.docker-compose}/bin/docker-compose --env-file .env up -d --remove-orphans
    '';

    preStop = ''
      ${pkgs.docker-compose}/bin/docker-compose down
    '';
  };

  systemd.services.dns-update = {
    description = "updates dns record";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.curl}/bin/curl -k "https://www.duckdns.org/update?domains=aletflix&token=${
          pkgs.secret "duckdns/token"
        }&ip="'';
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

  # homepage configuration
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    allowedHosts = "192.168.1.101:8082,localhost,127.0.0.1";

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
              href = "http://192.168.1.101:8096";
            };
          }
          {
            "Jellyseerr" = {
              icon = "jellyseerr.png";
              href = "http://192.168.1.101:5055";
            };
          }
        ];
      }
      {
        "Management" = [
          {
            "qBittorrent" = {
              icon = "qbittorrent.png";
              href = "http://192.168.1.101:8080";
            };
          }
          {
            "Radarr" = {
              icon = "radarr.png";
              href = "http://192.168.1.101:7878";
            };
          }
          {
            "Sonarr" = {
              icon = "sonarr.png";
              href = "http://192.168.1.101:8989";
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

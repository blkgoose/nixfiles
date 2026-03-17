{ pkgs, ... }: {
  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
    # allowedUDPPorts = [ 5353 ];
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

    otbr-agent = {
      image = "openthread/otbr:latest";
      volumes = [
        "/run/dbus:/run/dbus:ro"
        "/var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket"
      ];
      devices = [
        "/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_1CDBD45E7500-if00:/dev/ttyUSB0"
      ];
      extraOptions = [ "--network=host" "--privileged" ];

      environment = {
        OTBR_FEATURE_FLAGS = "-NAT64 -DNS64";
        NAT64 = "0";
        NAT44 = "0";
        FIREWALL = "0";
        OTBR_MDNS = "avahi";
        BACKBONE_INTERFACE = "enp1s0";
      };

      cmd = [
        "--name"
        "HA_Thread_Network"
        "--radio-url"
        "spinel+hdlc+uart:///dev/ttyUSB0?uart-baudrate=460800&flow-control=0"
      ];
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
    ipv6 = true;
    reflector = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
    allowInterfaces = [ "enp1s0" "wpan0" ];
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

  services.dbus.packages = [
    (pkgs.writeTextFile {
      name = "otbr-dbus-conf";
      destination = "/share/dbus-1/system.d/otbr.conf";
      text = ''
        <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
         "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
        <busconfig>
          <policy context="default">
            <allow own="io.openthread.BorderRouter.wpan0"/>
            <allow send_destination="io.openthread.BorderRouter.wpan0"/>
            <allow receive_sender="io.openthread.BorderRouter.wpan0"/>
          </policy>
        </busconfig>
      '';
    })
  ];

  networking.firewall.allowedUDPPorts = [ 5353 5683 8081 7682 61631 ];
  # DISABILITA il filtraggio dei pacchetti multicast (fondamentale per mDNS)
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p igmp -j ACCEPT
    iptables -A INPUT -p udp --dport 5353 -j ACCEPT
    ip6tables -A INPUT -p udp --dport 5353 -j ACCEPT
  '';
}

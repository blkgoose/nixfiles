{ pkgs, ... }: {
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.route_localnet" = 1;
    "net.ipv4.conf.enp2s0.route_localnet" = 1;
  };

  networking.firewall = { allowedTCPPorts = [ 8123 8081 49154 ]; };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      volumes = [
        "/mnt/data/config/homeassistant:/config"
        "/etc/localtime:/etc/localtime:ro"
        "/run/dbus:/run/dbus:ro"
      ];
      environment = { TZ = "Europe/Rome"; };

      extraOptions = [ "--network=host" "--privileged" ];
    };

    matter-server = {
      image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
      extraOptions = [ "--network=host" "--privileged" ];
      volumes = [ "/mnt/data/config/matter:/data" "/run/dbus:/run/dbus:ro" ];
    };

    otbr-agent = {
      image = "openthread/otbr:latest";
      volumes =
        [ "/mnt/data/config/otbr:/var/lib/thread" "/run/dbus:/run/dbus:ro" ];
      devices = [
        "/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_1CDBD45E7500-if00:/dev/ttyACM0"
      ];
      extraOptions = [
        "--network=host"
        "--privileged"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];

      environment = {
        OTBR_FEATURE_FLAGS = "-NAT64 -DNS64 -TREL";
        NAT64 = "0";
        NAT44 = "0";
        FIREWALL = "0";
        OTBR_MDNS = "none";
        BACKBONE_INTERFACE = "enp2s0";
        OTBR_REST_LISTEN_ADDR = "0.0.0.0";
      };

      cmd = [
        "--name"
        "HA_Thread_Network"
        "--radio-url"
        "spinel+hdlc+uart:///dev/ttyACM0?uart-baudrate=460800&flow-control=0"
        "--rest-listen-address"
        "0.0.0.0"
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

  system.activationScripts.home-assistant = ''
    DEST="/mnt/data/config/homeassistant"
    mkdir -p "$DEST/custom_components"
    mkdir -p "$DEST/dashboards"
    ${pkgs.rsync}/bin/rsync -av --checksum --exclude='hacs' ${./custom-components}/ "$DEST/custom_components/"
    ${pkgs.rsync}/bin/rsync -av --checksum ${./ha-config}/ "$DEST/"
    ${pkgs.rsync}/bin/rsync -av --checksum ${./ha-config/dashboards}/ "$DEST/dashboards/"
    chmod +x "$DEST/check_projector.sh"
    chown -R root:root "$DEST/custom_components"
    PATH="/run/current-system/sw/bin:$PATH" systemctl restart docker-homeassistant
  '';

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv6 = true;
    reflector = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
      domain = true;
      workstation = true;
    };
    allowInterfaces = [ "enp2s0" ];
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

  services.dbus = {
    enable = true;
    packages = [
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
              <allow send_interface="io.openthread.BorderRouter"/>
              <allow receive_interface="io.openthread.BorderRouter"/>
            </policy>
            <policy user="root">
              <allow own="io.openthread.BorderRouter.wpan0"/>
              <allow send_destination="io.openthread.BorderRouter.wpan0"/>
              <allow receive_sender="io.openthread.BorderRouter.wpan0"/>
            </policy>
          </busconfig>
        '';
      })
    ];
  };

  networking.firewall.allowedUDPPorts = [ 5683 7682 61631 ];

  networking.firewall.extraCommands = ''
    # Allow IGMP (multicast group management)
    iptables -A INPUT -p igmp -j ACCEPT

    # Allow mDNS INPUT on all interfaces (receive queries)
    iptables -A INPUT -p udp --dport 5353 -j ACCEPT
    ip6tables -A INPUT -p udp --dport 5353 -j ACCEPT

    # Allow mDNS OUTPUT on main network, localhost, and docker bridges
    iptables -A OUTPUT -o enp2s0 -p udp --dport 5353 -j ACCEPT
    iptables -A OUTPUT -o lo -p udp --dport 5353 -j ACCEPT
    iptables -A OUTPUT -o br+ -p udp --dport 5353 -j ACCEPT
    # Block mDNS on tailscale and individual veth interfaces
    iptables -A OUTPUT -o tailscale0 -p udp --dport 5353 -j DROP
    iptables -A OUTPUT -o veth+ -p udp --dport 5353 -j DROP

    ip6tables -A OUTPUT -o enp2s0 -p udp --dport 5353 -j ACCEPT
    ip6tables -A OUTPUT -o lo -p udp --dport 5353 -j ACCEPT
    ip6tables -A OUTPUT -o br+ -p udp --dport 5353 -j ACCEPT
    ip6tables -A OUTPUT -o tailscale0 -p udp --dport 5353 -j DROP
    ip6tables -A OUTPUT -o veth+ -p udp --dport 5353 -j DROP

    # DNAT for OTBR REST API: redirect external connections to port 8081 to localhost
    # This makes the REST API accessible from the network for Matter commissioning
    iptables -t nat -A PREROUTING -i enp2s0 -p tcp --dport 8081 -j DNAT --to-destination 127.0.0.1:8081
    iptables -t nat -A OUTPUT -p tcp --dport 8081 -d 192.168.1.101 -j DNAT --to-destination 127.0.0.1:8081
  '';

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"
    KERNEL=="ttyUSB*", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"
    KERNEL=="ttyUSB*", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"
    KERNEL=="ttyUSB*", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", MODE="0666", GROUP="dialout"
  '';
}

{ pkgs, ... }:
let
  port = 10000;
  stateDir = "/var/lib/trmnl-ha";
in
{
  networking.firewall.interfaces.enp2s0.allowedTCPPorts = [ port ];

  virtualisation.oci-containers.containers.trmnl-ha = {
    image = "ghcr.io/usetrmnl/trmnl-ha-amd64:latest";
    ports = [ "${toString port}:10000" ];
    volumes = [ "${stateDir}/data:/data" ];
    environmentFiles = [ "${stateDir}/env" ];
    environment = {
      HOME_ASSISTANT_URL = "http://192.168.1.101:8123";
      KEEP_BROWSER_OPEN = "true";
      TZ = "Europe/Rome";
    };
  };

  systemd.services.docker-trmnl-ha.preStart = ''
    ${pkgs.coreutils}/bin/install -d -m 755 ${stateDir}/data
    echo "ACCESS_TOKEN=$(${pkgs.coreutils}/bin/head -1 /var/lib/ha/homeassistant/ha_token)" > ${stateDir}/env
    ${pkgs.coreutils}/bin/chmod 600 ${stateDir}/env
  '';
}

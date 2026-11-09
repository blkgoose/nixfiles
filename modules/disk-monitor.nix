{ ip }:
{ pkgs, ... }: {
  services.ttyd = {
    enable = true;
    port = 7681;
    user = "root";
    writeable = false;
    entrypoint = [
      "${pkgs.iotop-c}/bin/iotop-c"
      "-o"
      "-P"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 7681 ];

  dashboard.homeLinks = [
    {
      "Disk I/O" = {
        icon = "mdi-harddisk";
        href = "http://${ip}:7681";
        description = "Live iotop";
      };
    }
  ];
}

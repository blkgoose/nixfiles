{ ip }:
{ pkgs, ... }: {
  services.netdata = {
    enable = true;
    package = pkgs.netdataCloud;
    config = {
      global = {
        "update every" = 2;
      };
      web = {
        "bind to" = "0.0.0.0:19999";
      };
      db = {
        "dbengine tier 0 retention time" = "14d";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 19999 ];

  dashboard.homeLinks = [
    {
      "Netdata" = {
        icon = "netdata.png";
        href = "http://${ip}:19999";
        description = "Disk I/O per app";
      };
    }
  ];
}

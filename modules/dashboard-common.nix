{ lib, config, ... }: {
  options.dashboard.homeLinks = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [ ];
  };

  config.services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    allowedHosts = "*";

    services = [ { "Home" = config.dashboard.homeLinks; } ];

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

    settings = {
      title = "NAS";
    };
  };
}

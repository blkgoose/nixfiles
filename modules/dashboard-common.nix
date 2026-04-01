{ ... }: {
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    allowedHosts = "*";

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

    settings = { title = "NAS"; };
  };
}

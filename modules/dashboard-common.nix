{ ... }: {
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

    settings = { title = "NAS"; };
  };
}

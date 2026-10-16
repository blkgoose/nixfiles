{ pkgs, ... }:
let
  port = 8085;
  app = pkgs.runCommand "calorie-tracker" { } ''
    mkdir -p $out
    cp ${./app.py} $out/app.py
    cp ${./index.html} $out/index.html
    cp ${./manifest.webmanifest} $out/manifest.webmanifest
    cp ${./sw.js} $out/sw.js
    cp ${./icon-192.png} $out/icon-192.png
    cp ${./icon-512.png} $out/icon-512.png
    cp ${./icon-512-maskable.png} $out/icon-512-maskable.png
    cp ${./apple-touch-icon.png} $out/apple-touch-icon.png
  '';
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  systemd.services.calorie-tracker = {
    description = "Calorie tracker";
    after = [
      "network.target"
      "docker-homeassistant.service"
    ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      PORT = toString port;
      HA_URL = "http://localhost:8123";
    };
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${app}/app.py";
      DynamicUser = true;
      StateDirectory = "calorie-tracker";
      LoadCredential = "ha_token:/mnt/data/config/homeassistant/ha_token";
      Restart = "on-failure";
    };
  };

  dashboard.homeLinks = [
    {
      "Calorie" = {
        icon = "mdi-food-apple";
        href = "http://192.168.1.101:${toString port}";
      };
    }
  ];
}

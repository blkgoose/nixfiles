{ pkgs, ... }:
let
  cloudflare-ca = ./cloudflare_ca.crt;
  cloudflare-ca-old = pkgs.fetchurl {
    url =
      "https://developers.cloudflare.com/cloudflare-one/static/Cloudflare_CA.pem";
    sha256 = "sha256-7p2+Y657zy1TZAsOnZIKk+7haQ9myGTDukKdmupHVNX=";
  };
in {
  nixpkgs.hostPlatform = "x86_64-linux";

  environment.etc."ssl/certs/cloudflare.crt".source = cloudflare-ca;
  environment.etc."ssl/certs/cloudflare-old.crt".source = cloudflare-ca-old;

  # remember to add user to docker group
  systemd.services.dockerd = {
    enable = true;
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.docker}/bin/dockerd";
    };
    description = "Runs docker daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.warp-svc = {
    enable = true;
    serviceConfig = { ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc"; };
    description = "Runs warp daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.earlyoom = {
    enable = true;
    serviceConfig = { ExecStart = "${pkgs.earlyoom}/bin/earlyoom"; };
    description = "Runs earlyOOM daemon";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.bigswap = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "bigswap" ''
        swapfile="/bigswap"
        if [[ ! -f $swapfile ]]; then
          ${pkgs.coreutils}/bin/dd if=/dev/zero of=$swapfile bs=1024 count=64GB
          ${pkgs.util-linux}/bin/mkswap $swapfile
          ${pkgs.coreutils}/bin/chmod 600 $swapfile
        fi
        ${pkgs.util-linux}/bin/swapon $swapfile
      ''}";
    };
    description = "Ensures 32GB swap file is created and enabled";
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.brightness-permission = {
    enable = true;
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.writeShellScript "brightness-permission" ''
        file="/sys/class/backlight/intel_backlight/brightness"
        ${pkgs.inotify-tools}/bin/inotifywait -e create "$file"

        chgrp video "$file"
        chmod g+w "$file"
      ''}";
    };
    description = "Sets permissions for xbacklight";
    wantedBy = [ "multi-user.target" ];
  };
}

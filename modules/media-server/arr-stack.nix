{ pkgs, ... }: {
  environment.etc = {
    "arr/docker-compose.yml".source = ./docker-compose.yml;
    "arr/.env".source = pkgs.writeText "env" ''
      NORDVPN_USER=${pkgs.secret "nordvpn/username"}
      NORDVPN_PASS=${pkgs.secret "nordvpn/password"}
    '';
  };

  systemd.services.arr-stack = {
    description = "arr-stack";
    after = [ "network.target" "mnt-data.mount" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      cd /etc/arr
      ${pkgs.docker-compose}/bin/docker-compose --env-file .env up -d --remove-orphans
    '';

    preStop = ''
      cd /etc/arr
      ${pkgs.docker-compose}/bin/docker-compose down
    '';
  };
}

{ pkgs, ... }: {
  environment.etc = {
    "arr/docker-compose.yml".source = ./docker-compose.yml;
    "arr/config/jellyfin-auto-collections/config.yaml".text = ''
      crontab: !ENV ''${CRONTAB}
      timezone: !ENV ''${TZ}
      jellyfin:
        server_url: !ENV ''${JELLYFIN_SERVER_URL}
        api_key: !ENV ''${JELLYFIN_API_KEY}
        user_id: !ENV ''${JELLYFIN_USER_ID}
      plugins:
        letterboxd:
          enabled: true
          list_ids:
            - arinbicer/list/mcu
    '';
    "arr/.env".source = pkgs.writeText "env" ''
      NORDVPN_USER=${pkgs.secret "nordvpn/username"}
      NORDVPN_PASS=${pkgs.secret "nordvpn/password"}
      JELLYFIN_API_KEY=${pkgs.secret "jellyfin/api_key"}
      JELLYFIN_USER_ID=${pkgs.secret "jellyfin/user_id"}
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
      ${pkgs.docker-compose}/bin/docker-compose --env-file .env up -d --pull always --remove-orphans
    '';

    preStop = ''
      cd /etc/arr
      ${pkgs.docker-compose}/bin/docker-compose down
    '';
  };
}

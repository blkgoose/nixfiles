{ pkgs, ... }:
let
  envFile = pkgs.writeText "env" ''
    NORDVPN_USER=${pkgs.secret "nordvpn/username"}
    NORDVPN_PASS=${pkgs.secret "nordvpn/password"}
    JELLYFIN_API_KEY=${pkgs.secret "jellyfin/api_key"}
    JELLYFIN_USER_ID=${pkgs.secret "jellyfin/user_id"}
  '';
in {
  environment.etc = {
    "arr/docker-compose.yml".source = ./docker-compose.yml;
    "arr/config/jellyfin-auto-collections/config.yaml".source =
      ./jellyfin-auto-collections.yaml;
    "arr/.env".source = envFile;
  };

  systemd.services.arr-stack = {
    description = "arr-stack";
    after = [ "network.target" "mnt-data.mount" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [
      (builtins.hashFile "sha256" ./docker-compose.yml)
      (builtins.hashFile "sha256" ./jellyfin-auto-collections.yaml)
      envFile
    ];

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

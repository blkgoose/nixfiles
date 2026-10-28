{ pkgs, ... }:
let
  port = 8086;

  python = pkgs.python3.withPackages (ps: [ ps.bcrypt ]);

  usersFile = pkgs.writeText "users.json" (pkgs.secret "sbobina/users.json");

  installUsers = pkgs.writeShellScript "install-users" ''
    ${pkgs.coreutils}/bin/install -m 600 ${usersFile} "$STATE_DIRECTORY/users.json"
  '';

  app = pkgs.runCommand "transcriber-server" { } ''
    mkdir -p $out
    cp ${./server.py} $out/server.py
    cp ${./index.html} $out/index.html
    cp ${./login.html} $out/login.html
  '';
in
{
  networking.firewall.interfaces.enp2s0.allowedTCPPorts = [ port ];

  systemd.services.transcriber-server = {
    description = "Transcription queue and web UI";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      HOST = "0.0.0.0";
      PORT = toString port;
      DATA_DIR = "/var/lib/transcriber";
      MODELS = builtins.toJSON [ "large-v3-turbo" ];
      ADMINS = "alessio";
      WAKE_MAC = "9c:6b:00:27:33:aa";
      WAKE_BROADCAST = "192.168.1.255";
    };
    serviceConfig = {
      ExecStartPre = installUsers;
      ExecStart = "${python}/bin/python3 ${app}/server.py";
      DynamicUser = true;
      StateDirectory = "transcriber";
      Restart = "on-failure";
    };
  };

  dashboard.homeLinks = [
    {
      "Sbobina" = {
        icon = "mdi-microphone";
        href = "http://192.168.1.101:${toString port}";
      };
    }
  ];
}

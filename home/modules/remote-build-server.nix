{ pkgs, ... }: {
  systemd.user.services.remote-build-server = {
    Unit = {
      Description = "Remote Build Server";
      After = [ "network.target" ];

    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.lspmux}/bin/lspmux server";
      Environment = [ "CARGO_HOME=/home/alessio-biancone/.cargo" ];
      Restart = "always";
      RestartSec = 5;
    };

    Install = { WantedBy = [ "default.target" ]; };
  };

  xdg.configFile."lspmux/config.toml".source = pkgs.writeText "lspmux-config" ''
    [[instance]]
    name = "rust-analyzer"
    server_path = "${pkgs.rust-analyzer}/bin/rust-analyzer"
    connect = ["0.0.0.0", 27631]
    pass_environment = ["*", "CARGO_HOME"]
  '';
}

{ pkgs, ... }:
let ip = "192.168.1.101"; # use DNS for better names
in {
  imports = [
    ./arr-stack.nix
    (import ./duckdns.nix {
      name = "aletflix";
      subdomains = [ "jellyfin" "seerr" ];
      token = pkgs.secret "duckdns/token";
    })
    (import ./homepage.nix { ip = "192.168.1.101"; })
  ];

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/duckdns@v0.5.0" ];
      hash = "sha256-BI72FyEpCKTyQ9lRlVcRsPLSyXlfwdOae57KhVTH/M8=";
    };
    globalConfig = ''
      email admin@aletflix.duckdns.org
      acme_ca https://acme-v02.api.letsencrypt.org/directory
    '';
    virtualHosts = {
      "jellyfin.aletflix.duckdns.org" = {
        extraConfig = ''
          tls {
            dns duckdns {env.DUCKDNS_TOKEN}
          }
          reverse_proxy localhost:8096
        '';
      };
      "seerr.aletflix.duckdns.org" = {
        extraConfig = ''
          tls {
            dns duckdns {env.DUCKDNS_TOKEN}
          }
          reverse_proxy localhost:5055
        '';
      };
    };
  };

  environment.etc."caddy/duckdns.env".text = ''
    DUCKDNS_TOKEN=${pkgs.secret "duckdns/token"}
  '';

  systemd.services.caddy.serviceConfig.EnvironmentFile = [ "/etc/caddy/duckdns.env" ];

  networking = {
    interfaces.enp1s0.ipv4.addresses = [{
      address = ip;
      prefixLength = 24;
    }];
    firewall.allowedTCPPorts = [ 22 80 443 8082 ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };
}

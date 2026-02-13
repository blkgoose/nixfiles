{ pkgs, ... }:
let ip = "192.168.1.101"; # use DNS for better names
in {
  imports = [
    ./arr-stack.nix
    (import ./duckdns.nix {
      name = "aletflix";
      token = pkgs.secret "duckdns/token";
    })
    (import ./homepage.nix { ip = "192.168.1.101"; })
  ];

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

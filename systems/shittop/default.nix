{ pkgs, ... }:
let
  cloudflare-ca = pkgs.fetchurl {
    url =
      "https://developers.cloudflare.com/cloudflare-one/static/Cloudflare_CA.pem";
    sha256 = "sha256-7p2+Y657zy1TZAsOnZIKk+7haQ9myGTDukKdmupHVNX=";
  };
in {
  nixpkgs.hostPlatform = "x86_64-linux";

  environment.etc."ssl/certs/cloudflare.crt".source = cloudflare-ca;

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
}

{ pkgs, secret_dots, ... }:
let
  cloudflare-ca = "${secret_dots}/warp/cloudflare-ca.crt";
in {
  environment.systemPackages = with pkgs; [ cloudflare-warp ];
  systemd.packages = with pkgs; [ cloudflare-warp ];
  systemd.targets.multi-user.wants = [ "warp-svc.service" ];

  security.pki.certificateFiles = [ cloudflare-ca ];
}

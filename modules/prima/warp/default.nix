{ pkgs, secrets, ... }:
let cloudflare-ca = "${secrets}/warp/cloudflare-ca.crt";
in {
  environment.systemPackages = with pkgs; [ cloudflare-warp ];
  systemd.packages = with pkgs; [ cloudflare-warp ];
  systemd.targets.multi-user.wants = [ "warp-svc.service" ];

  security.pki.certificateFiles = [ cloudflare-ca ];
}

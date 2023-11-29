{ secret_dots, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ cloudflare-warp ];
  systemd.packages = with pkgs; [ cloudflare-warp ];

  security.pki.certificateFiles =
    [ "${secret_dots}/vpn/warp/Cloudflare_CA.pem" ];
}

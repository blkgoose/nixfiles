{ secret_dots, ... }: {
  imports = [ ./cloudflare-warp.nix ];

  services.cloudflare-warp = {
    enable = true;
    certificate = "${secret_dots}/Cloudflare_CA.pem";
  };
}

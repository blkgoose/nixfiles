{ pkgs, prima-nix, secret_dots, ... }:
let
  vault_addr = builtins.head (builtins.split "\n"
    (builtins.readFile "${secret_dots}/vault/prima_address"));
in {
  imports = [ prima-nix.homeManagerModules.gitleaks ];

  home.packages = with pkgs; [
    suite_py
    cloudflare-warp
    cloudflared
    (alias "vault" "VAULT_ADDR=${vault_addr} ${(vault)}/bin/vault")
    unstable.bruno
    awscli2
  ];

  home.file = {
    ".npmrc".source = "${secret_dots}/npm/npmrc";
    ".cargo/credentials.toml".source = "${secret_dots}/cargo/credentials.toml";
    ".suite_py/config.yml".source = "${secret_dots}/suite_py/config.yml";
    ".config/starscli/config.yml".source = "${secret_dots}/starscli/config.yml";
  };

  prima.gitleaks.enable = true;
}

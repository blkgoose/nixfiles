{ pkgs, prima-nix, config, secrets, ... }:
let
  vault_addr = builtins.head
    (builtins.split "\n" (builtins.readFile "${secrets}/vault/prima_address"));

  secrets_dir =
    "${config.xdg.configHome}/nix/secrets/"; # TODO: make this more robust
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
    ".npmrc".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets_dir}/npm/npmrc";
    ".cargo/credentials.toml".source = config.lib.file.mkOutOfStoreSymlink
      "${secrets_dir}/cargo/credentials.toml";
    ".suite_py/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets_dir}/suite_py/config.yml";
    ".config/starscli/config.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets_dir}/starscli/config.yaml";
    ".aws/config".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets_dir}/aws/config";
  };

  prima.gitleaks.enable = true;
}

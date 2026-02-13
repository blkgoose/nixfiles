{ pkgs, prima-nix, config, ... }:
let
  secrets =
    "${config.xdg.configHome}/nix/secrets/"; # TODO: make this more robust
in {
  imports = [ prima-nix.homeManagerModules.gitleaks ];

  home.packages = with pkgs; [
    suite_py
    cloudflare-warp
    cloudflared
    (alias "vault"
      "VAULT_ADDR=${secret "vault/prima_address"} ${(vault)}/bin/vault")
    unstable.bruno
    awscli2
  ];

  home.file = {
    ".npmrc".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets}/npm/npmrc";
    ".cargo/credentials.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets}/cargo/credentials.toml";
    ".suite_py/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets}/suite_py/config.yml";
    ".config/starscli/config.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets}/starscli/config.yaml";
    ".aws/config".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets}/aws/config";
  };

  prima.gitleaks.enable = true;
}

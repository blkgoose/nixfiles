{ pkgs, prima-nix, secret_dots, config, ... }:
let
  vault_addr = builtins.head (builtins.split "\n"
    (builtins.readFile "${secret_dots}/vault/prima_address"));

  secrets = "${config.xdg.configHome}/nix/secret_dotfiles/";
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
      config.lib.file.mkOutOfStoreSymlink "${secrets}/npm/npmrc";
    ".cargo/credentials.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets}/cargo/credentials.toml";
    ".suite_py/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets}/suite_py/config.yml";
    ".config/starscli/config.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${secrets}/starscli/config.yaml";
  };

  prima.gitleaks.enable = true;
}

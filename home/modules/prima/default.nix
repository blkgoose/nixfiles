{ pkgs, prima-nix, secret_dots, ... }: {
  imports = [ prima-nix.homeManagerModules.gitleaks ];

  home.packages = with pkgs; [ suite_py cloudflare-warp ];

  home.file = {
    ".npmrc".source = "${secret_dots}/npm/npmrc";
    ".cargo/credentials.toml".source = "${secret_dots}/cargo/credentials.toml";
    ".suite_py/config.yml".source = "${secret_dots}/suite_py/config.yml";
  };

  prima.gitleaks.enable = true;
}

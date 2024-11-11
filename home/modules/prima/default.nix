{ pkgs, secret_dots, ... }: {
  imports = [ ./git.nix ];

  home.packages = with pkgs; [ suite_py cloudflare-warp ];

  home.file = {
    ".npmrc".source = "${secret_dots}/npm/npmrc";
    ".suite_py/config.yml".source = "${secret_dots}/suite_py/config.yml";
  };
}

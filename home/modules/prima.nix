{ pkgs, secret_dots, ... }: {
  home.packages = with pkgs; [ suite_py ];

  home.file = {
    ".npmrc".source = "${secret_dots}/npm/npmrc";
    ".suite_py/config.yml".source = "${secret_dots}/suite_py/config.yml";
  };
}

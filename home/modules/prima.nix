{ pkgs, secret_dots, ... }: {
  home.packages = with pkgs; [ suite_py ];

  home.file.".npmrc".source = "${secret_dots}/npm/npmrc";
}

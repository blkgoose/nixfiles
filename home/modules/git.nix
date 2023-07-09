{ pkgs, dots, ... }: {
  programs.git = { enable = true; };

  xdg.configFile = {
    "git/config".source = "${dots}/git/config";
    "git/ignore".source = "${dots}/git/ignore";
  };
}

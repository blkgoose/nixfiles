{ pkgs, dots, ... }: {
  home.file.".config/fish" = {
    source = "${dots}/fish";
    recursive = true;
  };

  programs.fish.enable = true;
}

{ pkgs, dots, ... }: {
  home.file.".config/fish" = {
    source = ./conf;
    recursive = true;
  };

  programs.fish.enable = true;
}

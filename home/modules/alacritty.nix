{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "RobotoMono Nerd Font Mono";
          style = "Regular";
        };
        size = 8.0;
      };
      terminal.shell.program = "${pkgs.fish}/bin/fish";
    };
  };
}

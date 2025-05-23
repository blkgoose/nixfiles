{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "RobotoMono Nerd Font";
          style = "Regular";
        };
        size = 11.0;
      };
      terminal.shell.program = "${pkgs.fish}/bin/fish";
    };
  };
}

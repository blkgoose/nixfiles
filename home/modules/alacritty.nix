{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "monospace";
          style = "Regular";
        };
      };
      terminal.shell.program = "${pkgs.fish}/bin/fish";
    };
  };
}

{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "RobotoMono Nerd Font Mono";
          style = "Regular";
        };
        size = 11.0;
      };
      terminal.shell.program = "${pkgs.fish}/bin/fish";
    };
  };

  home.packages = with pkgs; [ nerd-fonts.roboto-mono ];
}

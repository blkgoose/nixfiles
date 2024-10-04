{ ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "fish";
        args = [ "-c" "tmux attach || tmux" ];
      };
    };
  };
}

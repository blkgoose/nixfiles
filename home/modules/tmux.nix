{ pkgs, ... }: {
  programs.tmux = {
    enable = true;

    shell = "${pkgs.fish}/bin/fish";
    keyMode = "vi";

    extraConfig = ''
      bind -n m-H swap-pane -D
      bind -n m-L swap-pane -U
    '';
  };
}

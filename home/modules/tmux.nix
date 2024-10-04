{ pkgs, config, ... }: {
  home.packages = with pkgs; [ fzf unstable.sesh zoxide tmuxinator ];

  programs.tmux = {
    enable = true;

    shell = "${pkgs.fish}/bin/fish";
    keyMode = "vi";

    plugins = with pkgs; [{
      plugin = tmuxPlugins.sensible;
      extraConfig = "set -s escape-time 0";
    }];

    mouse = true;

    prefix = "C-Space";

    extraConfig = ''
      bind -n m-H swap-pane -D
      bind -n m-L swap-pane -U

      set -g detach-on-destroy off

      bind-key -n 'M-r' source-file "${config.xdg.configHome}/tmux/tmux.conf" \; display "Configuration Reloaded!"

      setw -g window-status-format " #I:#W "
      setw -g window-status-current-format " #I:#W "
      setw -g window-status-current-style fg=colour211

      bind -n 'M-,' previous-window
      bind -n 'M-.' next-window
      bind -n 'M-<' swap-window -t -1 \; previous-window
      bind -n 'M->' swap-window -t +1 \; next-window

      bind -n 'M-b' break-pane \; next-window
      bind -n 'M-j' choose-window 'join-pane -s "%%"'

      #sesh
      bind -n 'M-s' display-popup -E -w 40% "sesh connect \"$( sesh list -i | fzf --ansi )\""
      bind -n 'M-S' run-shell 'sesh last'
      bind -n 'M-k' kill-session
    '';
  };
}

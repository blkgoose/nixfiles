{ pkgs, config, ... }: {
  home.packages = with pkgs; [ fzf unstable.sesh zoxide tmuxinator ];

  # TODO: make this user scoped
  xdg.configFile."tmuxinator".source = config.lib.file.mkOutOfStoreSymlink
    "${config.xdg.configHome}/nix/home/modules/tmux/tmuxinator";

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
      bind v split-window -h
      bind h split-window -v

      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      bind -n M-H swap-pane -D
      bind -n M-L swap-pane -U

      set -g detach-on-destroy off

      bind-key R source-file "${config.xdg.configHome}/tmux/tmux.conf" \; display "Configuration Reloaded!"

      set -g status-justify centre
      set -g status-style fg=colour180

      setw -g window-status-format " #I:#W "
      setw -g window-status-current-format " #I:#W "
      setw -g window-status-current-style fg=colour211,bg=colour0

      bind -n 'M-,' previous-window
      bind -n 'M-.' next-window
      bind -n 'M-<' swap-window -t -1 \; previous-window
      bind -n 'M->' swap-window -t +1 \; next-window

      bind b break-pane \; next-window
      bind j choose-window 'join-pane -s "%%"'

      #sesh
      bind -n 'M-s' display-popup -E -w 40% "sesh connect \"$( sesh list -i | fzf --ansi )\""
      bind -n 'M-S' run-shell 'sesh last'
    '';
  };
}

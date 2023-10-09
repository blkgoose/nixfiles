{ ... }: {
  imports = [ ./dunst_notification_mapper ];

  xdg.configFile."dunst/dunstrc".source = ./dunstrc;
}

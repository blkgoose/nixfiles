{ pkgs, ... }:
let
  super = 125;
  shift = 42;
  caps = 58;
  vol_up = 114;
  vol_down = 115;
  next = 163;
  prev = 164;
  play_pause = 165;

  runAsUser = cmd: "/run/current-system/sw/bin/runuser -l alessio -c '${cmd}'";
in {
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      # music
      {
        keys = [ play_pause ];
        events = [ "key" ];
        command = runAsUser "${pkgs.playerctl}/bin/playerctl play-pause";
      }
      {
        keys = [ prev ];
        events = [ "key" ];
        command = runAsUser "${pkgs.playerctl}/bin/playerctl prev";
      }
      {
        keys = [ next ];
        events = [ "key" ];
        command = runAsUser "${pkgs.playerctl}/bin/playerctl next";
      }

      # volume
      {
        keys = [ vol_down ];
        events = [ "key" ];
        command = runAsUser
          "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%; volume_notification";
      }
      {
        keys = [ vol_up ];
        events = [ "key" ];
        command = runAsUser
          "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%; volume_notification";
      }

      # dunst
      {
        keys = [ super 17 ];
        events = [ "key" ];
        command = "${pkgs.dunst}/bin/dunstctl close";
      }
      {
        keys = [ super 18 ];
        events = [ "key" ];
        command = "${pkgs.dunst}/bin/dunstctl history-pop";
      }
      {
        keys = [ super 19 ];
        events = [ "key" ];
        command = "${pkgs.dunst}/bin/dunstctl context";
      }
      {
        keys = [ caps ];
        events = [ "key" ];
        command = "${pkgs.dunst}/bin/dunstctl set-paused toggle";
      }

      # spotify
      {
        keys = [ shift vol_down ];
        events = [ "key" ];
        command = runAsUser "spotify_volume_control 5%-";
      }
      {
        keys = [ shift vol_up ];
        events = [ "key" ];
        command = runAsUser "spotify_volume_control 5%+";
      }

      # monitor
      {
        keys = [ 99 ];
        events = [ "key" ];
        command = "xset dpms force off";
      }
      {
        keys = [ 70 ];
        events = [ "key" ];
        command = "systemctl suspend";
      }
      {
        keys = [ 104 ];
        events = [ "key" ];
        command = "dm-tool lock";
      }

      # brightness
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/wrappers/bin/light -A 10";
      }
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/wrappers/bin/light -U 10";
      }
    ];
  };
}

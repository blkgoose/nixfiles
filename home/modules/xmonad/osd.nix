{ pkgs, osd, ... }:
let
  stdbuf = "${pkgs.coreutils}/bin/stdbuf";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  grep = "${pkgs.gnugrep}/bin/grep";
  tr = "${pkgs.coreutils}/bin/tr";
  awk = "${pkgs.gawk}/bin/awk";
  dbus = "${pkgs.dbus}/bin/dbus-monitor";
in {
  imports = [ osd.homeManagerModules.osd ];

  osd = {
    enable = true;
    settings = {
      "brightness" = {
        source = "file";
        path = "/sys/class/backlight/intel_backlight/brightness";
        max = 19393;
      };
      "volume" = {
        source = "pipe";
        command = ''
          ${stdbuf} -oL ${pactl} subscribe | ${grep} --line-buffered "'change' on sink #" | while read -r line; do
              SINK_IDX=$(echo "$line" | ${grep} -oP 'sink #\K\d+')
              SINK_INFO=$(${pactl} list sinks | ${grep} -A 20 "Sink #$SINK_IDX" | ${awk} '/Volume:/ {print $5; exit}')
              echo "$SINK_INFO" | ${tr} -d '%'
          done
        '';
      };
      "volume:spotify" = {
        source = "pipe";
        command = ''
          ${dbus} "sender='org.mpris.MediaPlayer2.spotify'" \
              | ${stdbuf} -oL ${grep} 'string "Volume"' -A1 \
              | ${stdbuf} -oL ${awk} '/double/ { print $3 }'
        '';
        min = 0;
        max = 1;
      };
    };
  };
}

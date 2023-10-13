{ pkgs, lib, ... }:
let
  chrome_notification_mapper =
    pkgs.writers.writeBashBin "chrome_notification_mapper" ''
      appname="$1"
      summary="$2"
      body="$3"
      icon="$4"
      urgency="$5"

      declare -A icon_mapping
      icon_mapping["reddit"]="web-reddit"

      appname=$(echo "$body" \
        | ${pkgs.coreutils}/bin/head -1 \
        | ${pkgs.gnugrep}/bin/grep -oP ">[^.]*\.[^.]*" \
        | ${pkgs.coreutils}/bin/cut -d. -f2 \
      )
      body=$(echo "$body" \
        | ${pkgs.coreutils}/bin/tail -n+3 \
      )

      icon_default=$(echo "$appname" | ${pkgs.coreutils}/bin/tr "[:upper:]" "[:lower:]")
      icon=''${icon_mapping["$appname"]}

      # in case there is no overwriting icon to use
      if [[ -z "$icon" ]]; then
        icon="$icon_default"
      fi

      if [[ "$body" == "This site has been updated in the background." ]]; then
        exit 0
      fi

      # instagram
      if [[ "$appname" == "instagram" ]] && [[ "$body" == "You have unseen notifications." ]]; then
        exit 0
      fi

      if [[ "$appname" == "whatsapp" ]] && [[ "$body" == "Sincronizzazione dei messaggi in background in corso…" ]]; then
        exit 0
      fi

      # slack
      if [[ "$appname" == "slack" ]]; then
        if [[ "$summary" =~ "New message from".* ]]; then
            summary=$(echo "$summary" \
                | ${pkgs.gnused}/bin/sed "s/New message from //" \
            )
        fi

        if [[ "$summary" =~ "New message in".* ]]; then
            sender=$(echo "$body" \
                | ${pkgs.coreutils}/bin/head -1 \
                | ${pkgs.coreutils}/bin/cut -d: -f1 \
            )

            body=$(echo "$body" \
                | ${pkgs.coreutils}/bin/cut -d: -f2- \
                | ${pkgs.findutils}/bin/xargs \
            )

            group=$(echo "$summary" \
                | ${pkgs.gnused}/bin/sed "s/New message in //" \
            )

            summary="$sender @ $group"
        fi
      fi

      ${pkgs.dunst}/bin/dunstify \
        -a "''${appname^}" \
        -u "$urgency" \
        -i "$icon" \
        "$summary" \
        "$body"
    '';
in {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "keyboard";

        markup = "full";
        format = "<b>%a</b>\\n%s\\n\\n%b";

        width = 800;
        origin = "top-center";
        offset = "0x0";
        font = "Hack Nerd Font 11";
        transparency = 1;
        gap_size = 5;
        padding = 16;
        horizontal_padding = 16;
        frame_width = 0;
        separator_height = 6;
        shrink = "no";
        sort = "no";
        idle_threshold = 3600;
        line_height = 0;

        progress_bar = true;
        progress_bar_height = 14;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 350;

        notification_limit = 1;
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 30;
        word_wrap = "yes";
        ignore_newline = "no";
        stack_duplicates = true;
        show_indicators = "yes";
        icon_position = "left";
        enable_recursive_icon_lookup = true;
        icon_theme = "Papirus, hicolor";
        min_icon_size = 48;
        max_icon_size = 60;
        sticky_history = "yes";
        history_length = 100;
        dmenu = "/usr/local/bin/dmenu -p dunst:";
        browser = "chrome --new-window";
        mouse_left_click = "none";
        mouse_middle_click = "none";
        mouse_right_click = "none";

        title = "Dunst";
        class = "Dunst";
      };

      experimental.per_monitor_dpi = false;

      urgency_low = {
        highlight = "#6fa6e7";
        background = "#222222";
        frame_color = "#222222";
        foreground = "#dae1f2";
        timeout = 2;
      };

      urgency_normal = {
        highlight = "#5ca1ff";
        background = "#222222";
        frame_color = "#222222";
        foreground = "#dae1f2";
        timeout = 7;
      };

      urgency_critical = {
        background = "#fe6c5a";
        highlight = "#fafafa";
        foreground = "#1c2138";
        frame_color = "#52426e";
        timeout = 0;
      };

      spotify = {
        appname = "Spotify";
        urgency = "low";
      };

      spotify_volume = {
        appname = "volume:spotify";
        highlight = "#ff7ca4";
        format = "<b>%s</b>\\n";
        history_ignore = "yes";
      };

      brightness = {
        appname = "brightness";
        highlight = "#fddddd";
        format = "<b>%s</b>\\n";
        history_ignore = "yes";
      };

      volume = {
        appname = "volume";
        highlight = "#ff7ca4";
        format = "<b>%s</b>\\n";
        history_ignore = "yes";
      };

      battery = {
        appname = "battery";
        format = "<b>%s</b>\\n";
        history_ignore = "yes";
      };

      kdeconnect = {
        appname = "KDE Connect";
        format = "<b>%s</b>\\n\\n%b\\n";
      };

      chrome = {
        appname = "Google Chrome";
        script = lib.meta.getExe chrome_notification_mapper;
        format = "";
        skip_display = true;
        history_ignore = "yes";
      };
    };
  };
}

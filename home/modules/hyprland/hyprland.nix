{ pkgs, config, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$terminal" = "alacritty";

      monitor = ",preferred,auto,1";

      exec-once = [
        "hyprpaper &"
        "swayidle -w"
        "systemctl --user start waybar"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit"
      ];

      env = [
        "PATH, ${config.home.homeDirectory}/.local/bin:$PATH"
        "WLR_NO_HARDWARE_CURSORS, 1"
      ];

      input = {
        kb_layout = "us";
        kb_options = "compose:ralt,caps:none";

        follow_mouse = 1;

        touchpad = { natural_scroll = "no"; };

        sensitivity = 0;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";

        allow_tearing = false;
      };

      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        layerrule =
          [ "blur, waybar|swaync|wofi" "ignorezero, waybar|swaync|wofi" ];

        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = "yes";

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
        special_scale_factor = 0.85;
      };

      master = { new_status = "master"; };

      gestures = { workspace_swipe = "off"; };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      "$mainMod" = "SUPER";

      bind = [
        "$mainMod SHIFT, RETURN, exec, $terminal"
        "$mainMod SHIFT, C, killactive, "
        "$mainMod, V, togglefloating, "
        "$mainMod, P, exec, wofi --show run"
        "$mainMod, S, togglespecialworkspace,"
        "$mainMod SHIFT, S, movetoworkspace, special"
        "$mainMod, SPACE, pseudo, # dwindle"
        "$mainMod, RETURN, togglesplit, # dwindle"

        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"

        "$mainMod CONTROL, h, resizeactive, -50 0"
        "$mainMod CONTROL, l, resizeactive, 50 0"
        "$mainMod CONTROL, k, resizeactive, 0 -50"
        "$mainMod CONTROL, j, resizeactive, 0 50"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod, TAB, workspace, previous"

        ", xf86AudioRaiseVolume, exec, ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ", xf86AudioLowerVolume, exec, ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ", xf86AudioMute,        exec, ${pkgs.pulseaudioFull}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
        ", xf86AudioNext,        exec, ${pkgs.playerctl}/bin/playerctl next"
        ", xf86AudioPrev,        exec, ${pkgs.playerctl}/bin/playerctl previous"
        ", xf86AudioPlay,        exec, ${pkgs.playerctl}/bin/playerctl play-pause"

        "SHIFT, xf86AudioRaiseVolume, exec, ${pkgs.playerctl}/bin/playerctl --all-players volume 0.05+"
        "SHIFT, xf86AudioLowerVolume, exec, ${pkgs.playerctl}/bin/playerctl --all-players volume 0.05-"

        "$mainMod, e, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client --toggle-panel"
        "$mainMod, w, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client --hide-latest"

        ", xf86MonBrightnessUp  , exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%+"
        ", xf86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        ", switch:off:Lid Switch, exec, hyprctl reload"
        " , switch:on:Lid Switch, exec, hyprctl keyword monitor 'eDP-1, disable'"
      ];

      binds = { allow_workspace_cycles = "yes"; };
    };
  };
}

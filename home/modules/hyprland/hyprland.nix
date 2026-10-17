{
  pkgs,
  lib,
  config,
  ...
}:
let
  inline = lib.generators.mkLuaInline;

  # a bind whose key combo includes $mainMod (lua var `mod`)
  modBind = suffix: dispatcher: flags: {
    _args = [
      (inline ''mod .. " + ${suffix}"'')
      dispatcher
    ]
    ++ lib.optional (flags != { }) flags;
  };

  # a bind with no modifier (or a literal modifier combo not involving mod)
  plainBind = key: dispatcher: flags: {
    _args = [
      key
      dispatcher
    ]
    ++ lib.optional (flags != { }) flags;
  };

  dsp = expr: inline expr;
in
{
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.unstable.hyprland;
    configType = "lua";
    settings = {
      mod._var = "SUPER";
      terminal._var = "alacritty";

      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      };

      config = {
        ecosystem.no_update_news = true;

        input = {
          kb_layout = "us";
          kb_options = "compose:ralt,caps:none";

          follow_mouse = 1;

          touchpad = {
            natural_scroll = false;
          };

          sensitivity = 0;
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = {
            colors = [
              "rgba(33ccffee)"
              "rgba(00ff99ee)"
            ];
            angle = 45;
          };
          "col.inactive_border" = {
            colors = [ "rgba(595959aa)" ];
          };

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
        };

        dwindle = {
          preserve_split = true;
          special_scale_factor = 0.85;
        };

        master = {
          new_status = "master";
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        binds = {
          allow_workspace_cycles = true;
        };
      };

      exec_cmd = [
        "hyprpaper"
        "swayidle -w"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit"
        "hyprctl setcursor Adwaita 24"
      ];

      on._args = [
        "hyprland.start"
        (inline ''
          function()
                    hl.exec_cmd("systemctl --user start waybar")
                  end'')
      ];

      env = [
        {
          _args = [
            "PATH"
            (inline ''"${config.home.homeDirectory}/.local/bin:" .. os.getenv("PATH")'')
          ];
        }
      ];

      curve._args = [
        "myBezier"
        {
          type = "bezier";
          points = [
            [
              5.0e-2
              0.9
            ]
            [
              0.1
              1.05
            ]
          ];
        }
      ];

      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 7;
          bezier = "myBezier";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 7;
          bezier = "default";
          style = "popin 80%";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "borderangle";
          enabled = true;
          speed = 8;
          bezier = "default";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 7;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 6;
          bezier = "default";
        }
      ];

      layer_rule = {
        match.namespace = "waybar|swaync|wofi";
        blur = true;
        ignore_alpha = 0;
      };

      bind = [
        (modBind "SHIFT + RETURN" (dsp "hl.dsp.exec_cmd(terminal)") { })
        (modBind "SHIFT + C" (dsp "hl.dsp.window.close()") { })
        (modBind "SHIFT + E" (dsp "hl.dsp.exit()") { })
        (modBind "V" (dsp "hl.dsp.window.float({})") { })
        (modBind "P" (dsp ''hl.dsp.exec_cmd("wofi --show run")'') { })
        (modBind "S" (dsp "hl.dsp.workspace.toggle_special()") { })
        (modBind "SHIFT + S" (dsp ''hl.dsp.window.move({ workspace = "special" })'') { })
        (modBind "SPACE" (dsp "hl.dsp.window.pseudo({})") { })
        (modBind "RETURN" (dsp ''hl.dsp.layout("togglesplit")'') { })

        (modBind "h" (dsp ''hl.dsp.focus({ direction = "left" })'') { })
        (modBind "l" (dsp ''hl.dsp.focus({ direction = "right" })'') { })
        (modBind "k" (dsp ''hl.dsp.focus({ direction = "up" })'') { })
        (modBind "j" (dsp ''hl.dsp.focus({ direction = "down" })'') { })

        (modBind "SHIFT + h" (dsp ''hl.dsp.window.move({ direction = "left" })'') { })
        (modBind "SHIFT + l" (dsp ''hl.dsp.window.move({ direction = "right" })'') { })
        (modBind "SHIFT + k" (dsp ''hl.dsp.window.move({ direction = "up" })'') { })
        (modBind "SHIFT + j" (dsp ''hl.dsp.window.move({ direction = "down" })'') { })

        (modBind "CONTROL + h" (dsp "hl.dsp.window.resize({ x = -50, y = 0, relative = true })") { })
        (modBind "CONTROL + l" (dsp "hl.dsp.window.resize({ x = 50, y = 0, relative = true })") { })
        (modBind "CONTROL + k" (dsp "hl.dsp.window.resize({ x = 0, y = -50, relative = true })") { })
        (modBind "CONTROL + j" (dsp "hl.dsp.window.resize({ x = 0, y = 50, relative = true })") { })

        (modBind "1" (dsp ''hl.dsp.focus({ workspace = "1" })'') { })
        (modBind "2" (dsp ''hl.dsp.focus({ workspace = "2" })'') { })
        (modBind "3" (dsp ''hl.dsp.focus({ workspace = "3" })'') { })
        (modBind "4" (dsp ''hl.dsp.focus({ workspace = "4" })'') { })
        (modBind "5" (dsp ''hl.dsp.focus({ workspace = "5" })'') { })
        (modBind "6" (dsp ''hl.dsp.focus({ workspace = "6" })'') { })
        (modBind "7" (dsp ''hl.dsp.focus({ workspace = "7" })'') { })
        (modBind "8" (dsp ''hl.dsp.focus({ workspace = "8" })'') { })
        (modBind "9" (dsp ''hl.dsp.focus({ workspace = "9" })'') { })
        (modBind "0" (dsp ''hl.dsp.focus({ workspace = "10" })'') { })

        (modBind "SHIFT + 1" (dsp ''hl.dsp.window.move({ workspace = "1" })'') { })
        (modBind "SHIFT + 2" (dsp ''hl.dsp.window.move({ workspace = "2" })'') { })
        (modBind "SHIFT + 3" (dsp ''hl.dsp.window.move({ workspace = "3" })'') { })
        (modBind "SHIFT + 4" (dsp ''hl.dsp.window.move({ workspace = "4" })'') { })
        (modBind "SHIFT + 5" (dsp ''hl.dsp.window.move({ workspace = "5" })'') { })
        (modBind "SHIFT + 6" (dsp ''hl.dsp.window.move({ workspace = "6" })'') { })
        (modBind "SHIFT + 7" (dsp ''hl.dsp.window.move({ workspace = "7" })'') { })
        (modBind "SHIFT + 8" (dsp ''hl.dsp.window.move({ workspace = "8" })'') { })
        (modBind "SHIFT + 9" (dsp ''hl.dsp.window.move({ workspace = "9" })'') { })
        (modBind "SHIFT + 0" (dsp ''hl.dsp.window.move({ workspace = "10" })'') { })

        (modBind "TAB" (dsp ''hl.dsp.focus({ workspace = "previous" })'') { })

        (plainBind "XF86AudioRaiseVolume"
          (dsp ''hl.dsp.exec_cmd("${pkgs.pulseaudioFull}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%")'')
          { }
        )
        (plainBind "XF86AudioLowerVolume"
          (dsp ''hl.dsp.exec_cmd("${pkgs.pulseaudioFull}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%")'')
          { }
        )
        (plainBind "XF86AudioMute"
          (dsp ''hl.dsp.exec_cmd("${pkgs.pulseaudioFull}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle")'')
          { }
        )
        (plainBind "XF86AudioNext" (dsp ''hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl next")'') { })
        (plainBind "XF86AudioPrev" (dsp ''hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl previous")'')
          { }
        )
        (plainBind "XF86AudioPlay" (dsp ''hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl play-pause")'')
          { }
        )

        (plainBind "SHIFT + XF86AudioRaiseVolume"
          (dsp ''hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl --all-players volume 0.05+")'')
          { }
        )
        (plainBind "SHIFT + XF86AudioLowerVolume"
          (dsp ''hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl --all-players volume 0.05-")'')
          { }
        )

        (modBind "m"
          (dsp ''hl.dsp.exec_cmd("${pkgs.swaynotificationcenter}/bin/swaync-client --toggle-panel")'')
          { }
        )
        (modBind "SHIFT + m"
          (dsp ''hl.dsp.exec_cmd("${pkgs.swaynotificationcenter}/bin/swaync-client --hide-latest")'')
          { }
        )

        (plainBind "XF86MonBrightnessUp"
          (dsp ''hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl set 10%+")'')
          { }
        )
        (plainBind "XF86MonBrightnessDown"
          (dsp ''hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl set 10%-")'')
          { }
        )

        (modBind "mouse:272" (dsp "hl.dsp.window.drag()") { })
        (modBind "mouse:273" (dsp "hl.dsp.window.resize()") { })
      ];
    };
  };
}

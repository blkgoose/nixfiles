{ pkgs, ... }:
let
  conf = pkgs.writeText "waybar" ''
    {
        "layer": "top",
        "position": "top",
        "modules-left": [ "hyprland/workspaces", "hyprland/window" ],
        "modules-center": [ "clock" ],
        "modules-right": [ "custom/spotify", "pulseaudio", "battery", "cpu", "custom/notification" ],

        "hyprland/workspaces": {
            "all-outputs": true,
        },

        "clock": {
            "format": "  {:%a %b %d  %I:%M %p}",
            "tooltip": false
        },

        "battery": {
            "states": {
                "warning": 30,
                "critical": 15,
                "full": 95,
            },
            "format": "{time} {icon}",
            "format-full": "",
            "format-icons": ["", "", "", "", ""],
            "tooltip": false
        },

        "cpu": {
            "interval": 2,
            "format": "{usage}% ",
            "tooltip": false
        },

        "pulseaudio": {
            "format": "{volume}% {icon}",
            "format-bluetooth": "{volume}% {icon} 󰂯",
            "format-bluetooth-muted": "󰖁 {icon} 󰂯",
            "format-muted": "󰖁 {format_source}",
            "format-source": "{volume}% ",
            "format-source-muted": "",
            "format-icons": {
                "headphone": "󰋋",
                "hands-free": "󱡒",
                "headset": "󰋎",
                "phone": "",
                "portable": "",
                "car": "",
                "default": ["", "", ""]
            }
        },

        "custom/spotify": {
            "interval": 1,
            "exec": "${pkgs.playerctl}/bin/playerctl metadata --player spotify --format '{{ title }} - {{ artist }}'",
            "exec-if": "${pkgs.playerctl}/bin/playerctl --player spotify status | ${pkgs.gnugrep}/bin/grep -q 'Playing'",
            "format": "{} ",
            "tooltip": false
        },

        "custom/notification": {
            "tooltip": false,
            "format": "{icon}",
            "format-icons": {
                "notification": "<span foreground='red'><sup></sup></span>",
                "none": "",
                "dnd-notification": "<span foreground='red'><sup></sup></span>",
                "dnd-none": "",
                "inhibited-notification": "<span foreground='red'><sup></sup></span>",
                "inhibited-none": "",
                "dnd-inhibited-notification": "<span foreground='red'><sup></sup></span>",
                "dnd-inhibited-none": ""
            },
            "return-type": "json",
            "exec": "${pkgs.swaynotificationcenter}/bin/swaync-client -swb",
            "escape": true
          }
    }
  '';

  style = pkgs.writeText "waybar" ''
    window > box {
      background: rgba(75, 75, 75, 0.3);

      margin: 10px;
      margin-bottom: 0;
      border-radius: 20px;
    }

    window#waybar {
      background: transparent;
      color: #e5e9f0;
    }

    #workspaces > * {
      transition: all 0.5s;
    }

    #workspaces button {
      color: #ffffff;
      border: none;
      border-radius: 100%;
      margin: 0 2px;
    }

    #workspaces button.focused {
      background: #4c566a;
    }

    #workspaces button:hover {
      background: rgba(75, 75, 75, 0.2);
    }

    #workspaces button.active {
      background: rgba(255, 255, 255, 0.3);
      color: black;
    }

    #workspaces button.urgent {
      background-color: #bf616a;
    }


    .modules-right * {
      padding: 0 5px;
      margin: 0 5px;
    }

    .modules-left,
    .modules-center,
    .modules-right {
      background: rgba(255, 255, 255, 0.1);
      border-radius: 20px;
      padding: 0 20px;
    }

    .modules-right {
      padding-right: 30px;
    }

    #workspaces {
      margin-right: 20px;
    }
  '';
in {
  home.file.".config/waybar/config".source = conf;
  home.file.".config/waybar/style.css".source = style;
}

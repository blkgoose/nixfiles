{ pkgs, ... }:
let
  conf = pkgs.writeText "waybar" ''
    {
        "layer": "top",
        "position": "top",
        "modules-left": [ "hyprland/workspaces", "hyprland/window" ],
        "modules-center": [ "clock" ],
        "modules-right": [ "pulseaudio", "battery", "cpu" ],

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
            "format": "{capacity}% {icon}",
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

    #clock,
    #battery,
    #cpu,
    #memory,
    #temperature,
    #backlight,
    #network,
    #pulseaudio,
    #custom-media,
    #tray,
    #mode,
    #idle_inhibitor {
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

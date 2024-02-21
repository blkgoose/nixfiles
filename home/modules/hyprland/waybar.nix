{ pkgs, ... }:
let
  conf = pkgs.writeText "waybar" ''
    {
        "layer": "top",
        "position": "top",
        "modules-left": [ "hyprland/workspaces", "hyprland/window" ],
        "modules-center": [ "clock" ],
        "modules-right": [ "pulseaudio", "cpu", "temperature", "memory" ],
        "spacing": 2,

        "hyprland/workspaces": {
            "all-outputs": true,
        },

        "clock": {
            "interval": 60,
            "format": "  {:%a %b %d  %I:%M %p}", // %b %d %Y  --Date formatting
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
            "format-alt": "{:%Y-%m-%d}"
        },

       "temperature": {
            // "thermal-zone": 2,
            // "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
            // "format-critical": "{temperatureC}°C {icon}",
            "critical-threshold": 80,
            "interval": 2,
            "format": "{temperatureC}°C ",
            "format-icons": ["", "", ""]
        },

        "cpu": {
            "interval": 2,
            "format": "{usage}% ",
            "tooltip": false
        },

        "memory": {
            "interval": 2,
            "format": "{}% "
        },

        "pulseaudio": {
            "format": "{volume}% {icon}", //{format_source}",
            "format-bluetooth": "{volume}% {icon} 󰂯", //{format_source}",
            "format-bluetooth-muted": "󰖁 {icon} 󰂯", //{format_source}",
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

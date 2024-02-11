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
            "format": "{icon}",
            "format-icons": {
                "active": "",
             },
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
in { home.file.".config/waybar/config".source = conf; }

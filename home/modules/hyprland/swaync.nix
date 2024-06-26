{ pkgs, ... }:
let
  conf = pkgs.writeText "swaync-conf" ''
    {
        "hide-on-clear": true
    }
  '';

  style = pkgs.writeText "swaync-style" ''
    * {
        all: unset;
        font-size: 14px;
        font-family: "Hack Nerd Font";
        transition: 200ms;
    }

    .notification {
        background: rgba(75, 75, 75, 0.6);
        min-height: 75px;
        padding: 10px;
        border-radius: 20px;
    }

    .critical {
        background: rgba(255, 0, 0, 0.3);
    }

    .floating-notifications .notification-row {
        background: rgba(75, 75, 75, 0.3);
        padding: 10px;
        padding-bottom: 0;
        margin: 0 10px;
    }

    .floating-notifications .notification-row:first-child {
        margin-top: 10px;
        border-top-left-radius: 20px;
        border-top-right-radius: 20px;
    }

    .floating-notifications .notification-row:last-child {
        border-bottom-left-radius: 20px;
        border-bottom-right-radius: 20px;
        padding-bottom: 10px;
    }

    .control-center {
        background: rgba(75, 75, 75, 0.3);
        margin: 10px;
        border-radius: 20px;
    }

    .control-center .notification-row {
        padding: 10px;
        padding-bottom: 0;
    }

    .control-center .notification-row:last-child {
        padding-bottom: 10px;
    }

    .control-center .widget-title,
    .widget-dnd {
        font-size: 70px;
        font-weight: bold;
        padding: 10px;
    }

    .control-center .widget-title button {
        font-size: 100px;
        font-weight: normal;
        padding: 10px;
        background: rgba(75, 75, 75, 0.8);
        border-radius: 20px;
    }

    .widget-dnd > switch {
        border-radius: 20px;
        background: rgba(75, 75, 75, 0.3);
        border: 1px solid rgba(75, 75, 75, 0.8);
    }

    .widget-dnd > switch:checked {
        background: rgba(255, 0, 0, 0.3);
    }

    .widget-dnd > switch slider {
        background: rgba(75, 75, 75, 1);
        border-radius: 20px;
    }
  '';
in {
  home.packages = with pkgs; [ swaynotificationcenter ];

  xdg.configFile = {
    "swaync/config.json".source = conf;
    "swaync/style.css".source = style;
  };

  systemd.user.services.swaync = {
    Unit = {
      Description = "Sway Notifications Center";
      PartOf = [ "graphical-session.target" ];
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      ExecReload = ''
        ${pkgs.swaynotificationcenter}/bin/swaync-client --reload-config;
        ${pkgs.swaynotificationcenter}/bin/swaync-client --reload-css;
      '';
      RestartSec = 5;
      Restart = "always";
    };
  };
}

{ pkgs, ... }: {
  programs.xmobar = {
    enable = true;
    extraConfig = ''
      Config { template = "    %XMonadLog% } %time% {%battery% [%cpu% %thermal0%] %memory%    "
             , bgColor = "#212121"
             , fgColor = "#F5F5F5"
             , font = "xft:monospace:size=10"
             , position = TopHM 40 10 10 10 0
             , commands = [ Run Cpu [ "--template", " <total>%"
                                    , "-L", "3"
                                    , "-H", "50"
                                    , "--high", "red"
                                    ] 10
                          , Run ThermalZone 0 [ "--template", "<temp>°C"
                                              , "--Low", "20"
                                              , "--High", "80"
                                              , "--high", "red"
                                              ] 10
                          , Run Memory [ "--template", " <usedratio>%"
                                       , "--high", "red"
                                       ] 10
                          , Run Battery [ "--template", "<acstatus>"
                                        , "--Low", "10"
                                        , "--High", "80"
                                        , "--low", "red"
                                        , "--"
                                        , "-o", "󰁹 <left>% (<timeleft>)"
                                        , "-O", "󰁹 <left>%+ (<timeleft>)"
                                        , "-i", ""
                                        ] 10
                          , Run Date "%H:%M:%S" "time" 10
                          , Run XMonadLog
                          ]
             , sepChar = "%"
             , alignSep = "}{"
             }
    '';
  };

  systemd.user.services.xmobar = {
    Unit.Description = "Runs xmobar";
    Service.ExecStart = "${pkgs.xmobar}/bin/xmobar";
    Install.WantedBy = [ "graphical-session.target" ];

    Unit = {
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
  };

  xdg.configFile."xmobar/.xmobarrc".onChange =
    "${pkgs.systemd}/bin/systemctl --user restart xmobar";
}

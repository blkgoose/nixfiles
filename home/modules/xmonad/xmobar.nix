{ pkgs, ... }: {
  programs.xmobar = {
    enable = true;
    extraConfig = ''
      Config { template = "%cpu% | %memory% * %swap% }{<fc=#ee9a00>%date%</fc>"
             , bgColor = "#212121"
             , fgColor = "#F5F5F5"
             , position = TopHM 50 10 10 10 0
             , commands = [ Run Cpu ["-L","3","-H","50","--normal","green","--high","red"] 10
                          , Run Memory ["-t","Mem: <usedratio>%"] 10
                          , Run Swap [] 10
                          , Run Date "%a %b %_d %Y %H:%M:%S" "date" 10
                          ]
             , sepChar = "%"
             , alignSep = "}{"
             }
    '';
  };

  systemd.user.services."xmobar" = {
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

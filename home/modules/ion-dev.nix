# temporary: used by toaster
{ pkgs, ... }:
let
  mkClaudeService = name: dir: {
    Unit = { Description = "Claude (${name})"; After = [ "network.target" ]; };

    Service = {
      Type = "simple";
      WorkingDirectory = dir;
      ExecStart = "${pkgs.writeShellScript "claude-remote-control-${name}" ''
        ${pkgs.claude-code}/bin/claude remote-control -c
        exec ${pkgs.claude-code}/bin/claude remote-control
      ''}";
      Restart = "always";
      RestartSec = 5;
    };

    Install = { WantedBy = [ "default.target" ]; };
  };
in {
  systemd.user.services = {
    claude-ion-og =
      mkClaudeService "ion-og" "%h/proj/ion-og";
    claude-helion =
      mkClaudeService "helion" "%h/proj/helion";
    claude-cdn-ion =
      mkClaudeService "cdn-ion" "%h/proj/cdn-ion";
  };
}

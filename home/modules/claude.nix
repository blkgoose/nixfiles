{ pkgs, ... }:
let
  mkClaudeService = name: dir: {
    Unit = {
      Description = "Claude (${name})";
      After = [ "network.target" ];
    };

    Service = {
      Type = "simple";
      WorkingDirectory = dir;
      ExecStart = "${pkgs.writeShellScript "claude-remote-control-${name}" ''
        ${pkgs.unstable.claude-code}/bin/claude remote-control --name ${name} -c
        exec ${pkgs.unstable.claude-code}/bin/claude remote-control --name ${name}
      ''}";
      Restart = "always";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
in
{
  systemd.user.services = {
    claude-ion-og = mkClaudeService "ion-og" "%h/proj/ion-og";
    claude-helion = mkClaudeService "helion" "%h/proj/helion";
    claude-cdn-ion = mkClaudeService "cdn-ion" "%h/proj/cdn-ion";
    claude-nix = mkClaudeService "nix" "%h/.config/nix";
  };
}

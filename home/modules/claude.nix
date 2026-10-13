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
        session_name="${name} $(date '+%Y-%m-%d %-H:%M')"
        ${pkgs.unstable.claude-code}/bin/claude remote-control --name "$session_name" -c
        exec ${pkgs.unstable.claude-code}/bin/claude remote-control --name "$session_name"
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
    claude-ion = mkClaudeService "ion" "%h/proj/ion-og";
    claude-helion = mkClaudeService "helion" "%h/proj/helion";
    claude-cdn-ion = mkClaudeService "cdn-ion" "%h/proj/cdn-ion";
    claude-nix = mkClaudeService "nix" "%h/.config/nix";
  };
}

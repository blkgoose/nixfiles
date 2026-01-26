{ pkgs, ... }: {
  home.packages = with pkgs; [ unstable.opencode ];

  xdg.configFile."opencode/config.json".source = pkgs.writeText "config.json" ''
    {
        "$schema": "https://opencode.ai/config.json",
        "model": "github-copilot/claude-sonnet-4.5"
    }
  '';
}

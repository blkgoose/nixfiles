{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs_22
    rustup
    nixfmt-classic
    clang
    yarn
    kubectl
    pkg-config
    openssl
    fh
    (alias "nh" ''sudo "$(which "${pkgs.nh}/bin/nh")"'')
    gh
    github-copilot-cli
    (alias "gemini-cli"
      "${(gemini-cli)}/bin/gemini --model gemini-2.5-flash --yolo")
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.opencode = {
    enable = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      "autoupdate" = true;
      "permission" = { # https://opencode.ai/docs/permissions
        "*" = "allow";
        "bash" = {
          "*" = "allow";
          "git push*" = "ask";
          "rm *" = "deny";
        };
        "skill" = {
          "*" = "allow";
          "caveman" = "allow";
        };
      };
    };
  };
}

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
        "*" = "ask";
        "read" = { "*" = "allow"; };
        "edit" = {
          "*" = "ask";
          "*.rs" = "allow";
          "*.py" = "allow";
          "*.ts" = "allow";
          "Cargo.toml" = "allow";
        };
        "glob" = "allow";
        "grep" = "allow";
        "list" = "allow";
        "bash" = {
          "*" = "ask";
          "git*" = "allow";
          "git push*" = "ask";
          "gh pr create*" = "ask";
          "gh api*" = "allow";
          "gh auth*" = "allow";
          "cargo*" = "allow";
          "grep*" = "allow";
          "ls*" = "allow";
          "which*" = "allow";
          "echo*" = "allow";
          "cat*" = "allow";
          "npm*" = "allow";
          "nix*" = "allow";
          "node*" = "allow";
          "pnpm*" = "allow";
          "yarn*" = "allow";
          "head*" = "allow";
          "rm *" = "deny";
        };
        "skill" = {
          "*" = "ask";
          "caveman" = "allow";
        };
        "lsp" = "allow";
        "question" = "allow";
        "todowrite" = "allow";
      };
    };
  };
}

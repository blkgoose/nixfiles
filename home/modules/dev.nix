{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs_22
    rustup
    sccache
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

  systemd.user.sessionVariables = {
    CARGO_TARGET_DIR = "/media/data/cargo-target";
    RUSTC_WRAPPER = "sccache";
    SCCACHE_DIR = "/media/data/sccache";
    SCCACHE_CACHE_SIZE = "20G";
    CARGO_INCREMENTAL = "0";
  };

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

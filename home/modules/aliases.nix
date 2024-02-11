{ lib, pkgs, ... }:
let
  apps = {
    "screenshot" = "${pkgs.escrotum}/bin/escrotum --select --clipboard";
    "chrome" = "${pkgs.google-chrome}/bin/google-chrome-stable";
    "beekeeper" = "${pkgs.beekeeper-studio}/bin/beekeeper-studio";
    "zoom" = "${pkgs.zoom-us}/bin/zoom";
    "vim" = "${pkgs.neovim-nightly}/bin/nvim";
  };

  mkAlias = name: command: {
    name = ".local/bin/${name}";
    value = {
      text = ''
        #!/usr/bin/env bash

        ${command} "$@"
      '';
      executable = true;
    };
  };
in { home.file = lib.attrsets.mapAttrs' mkAlias apps; }

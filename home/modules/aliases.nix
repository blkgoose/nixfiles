{ lib, pkgs, ... }:
let
  apps = {
    "screenshot" = "escrotum --select --clipboard";
    "chrome" = "google-chrome-stable";
    "beekeeper" = pkgs.writers.writeBash "beekeeper" ''
      ${pkgs.sqlite}/bin/sqlite3 ~/.config/beekeeper-studio/app.db "UPDATE saved_connection SET host = 'postgres-$QA_HASH.prima.qa' WHERE name = 'QA'"
      ${pkgs.beekeeper-studio}/bin/beekeeper-studio
    '';
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

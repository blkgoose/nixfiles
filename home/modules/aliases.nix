{ lib, ... }:
let
  apps = {
    "screenshot" = "escrotum --select --clipboard";
    "chrome" = "google-chrome-stable";
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

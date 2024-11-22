{ lib, pkgs, ... }:
# DEPRECATED. USE `pkgs.writeShellApplication` INSTEAD
let
  apps = {
    "chrome" = with pkgs; "${(nixGL google-chrome)}/bin/google-chrome-stable";
    "beekeeper" = "${pkgs.beekeeper-studio}/bin/beekeeper-studio";
    "zoom" = "${pkgs.zoom-us}/bin/zoom";
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

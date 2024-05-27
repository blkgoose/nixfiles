{ lib, pkgs, ... }:
let
  apps = {
    "screenshot" =
      "${pkgs.unstable.hyprshot}/bin/hyprshot --mode region --clipboard-only --silent";
    "chrome" = "${pkgs.google-chrome}/bin/google-chrome-stable";
    "beekeeper" = "${pkgs.beekeeper-studio}/bin/beekeeper-studio";
    "zoom" = "${pkgs.zoom-us}/bin/zoom";
    "lock" = ''
      ${pkgs.swaylock-effects}/bin/swaylock \
            --screenshot \
            --clock \
            --indicator \
            --effect-blur 7x5 \
            --grace 2 \
            --fade-in 0.2
    '';
    "mirror" = ''
      ${pkgs.wdomirror}/bin/wdomirror $(${pkgs.wdomirror}/bin/wdomirror  \
            | ${pkgs.gnugrep}/bin/grep -oP '(?<=ID: )\d+'  \
            | ${pkgs.coreutils}/bin/head -1) \
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

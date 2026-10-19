# Home-manager module that patches DankMaterialShell (stable) so the island
#  - rises to the overlay layer only while expanded or showing a notification/OSD
#    and fades in/out over fullscreen windows (needs islandOverlayWhenActive = true
#    in the bar config)
#  - keeps the notification center loaded, avoiding a ~6s delay on the next open
#  - refreshes the island text/icon and the history entry when a notification is replaced in place
#
# Usage, with the DMS flake input passed through extraSpecialArgs:
#   imports = [ dms.homeModules.dank-material-shell ./modules/dms-island-fixes ];
#   programs.dank-material-shell.islandFixes.enable = true;
{
  pkgs,
  lib,
  config,
  dms,
  ...
}:
let
  cfg = config.programs.dank-material-shell.islandFixes;
in
{
  options.programs.dank-material-shell.islandFixes = {
    enable = lib.mkEnableOption "island overlay/fade and notification center patches for DMS";
    overlayWhenActive = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply the overlay layer and fade patch.";
    };
    keepNotificationCenterLoaded = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply the patch that keeps the notification center loaded.";
    };
    refreshNotificationOnReplace = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply the patch that updates the island when a notification is replaced in place.";
    };
    expandSelectedHistory = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply the patch that toggles the keyboard-selected notification history entry with Enter.";
    };
    biggerNotificationText = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply the patch that enlarges the text and face of the expanded island notification.";
    };
    biggerCenterNotificationText = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply the patch that enlarges the text of notification center and history cards.";
    };
    refreshHistoryOnReplace = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Apply the patch that updates the notification history entry when a notification is replaced in place.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.dank-material-shell.package =
      dms.packages.${pkgs.stdenv.hostPlatform.system}.dms-shell.overrideAttrs
        (old: {
          # the patches are diffs against the upstream repo root; the QML is installed without the quickshell/ prefix
          postInstall =
            old.postInstall
            + ''
              chmod -R u+w $out/share/quickshell/dms/Modules/DankIsland $out/share/quickshell/dms/Modules/Notifications/Center $out/share/quickshell/dms/Services
            ''
            + lib.optionalString cfg.overlayWhenActive ''
              patch -p2 -d $out/share/quickshell/dms < ${./island-overlay-fade.patch}
            ''
            + lib.optionalString cfg.keepNotificationCenterLoaded ''
              patch -p2 -d $out/share/quickshell/dms < ${./keep-notification-center-loaded.patch}
            ''
            + lib.optionalString cfg.refreshNotificationOnReplace ''
              patch -p2 -d $out/share/quickshell/dms < ${./island-notification-refresh.patch}
            ''
            + lib.optionalString cfg.expandSelectedHistory ''
              patch -p2 -d $out/share/quickshell/dms < ${./history-expand-selected.patch}
            ''
            + lib.optionalString cfg.biggerNotificationText ''
              patch -p2 -d $out/share/quickshell/dms < ${./island-notification-font.patch}
            ''
            + lib.optionalString cfg.biggerCenterNotificationText ''
              patch -p2 -d $out/share/quickshell/dms < ${./center-notification-font.patch}
            ''
            + lib.optionalString cfg.refreshHistoryOnReplace ''
              patch -p2 -d $out/share/quickshell/dms < ${./history-refresh.patch}
            '';
        });
  };
}

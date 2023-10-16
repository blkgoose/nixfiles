{ lib, pkgs, ... }:
let
  ignored_apps = [
    "^whatis$"
    "^slabtop$"
    "^netcap$"
    "^parec.*$"
    "^parse_.*$"
    "^parse..*$"
    "^parted$"
    "^djvuxmlparser$"
    "^gpgparsemail$"
    "^link-parser$"
    "^p3dcparse$"
    "^tr$"
    "^tracegen.*$"
    "^tracepath$"
    "^traceroute$"
    "^tabs$"
    "^tac$"
    "^tracker3$"
    "^photorec$"
    "^nix$"
    "^nixfmt$"
    "^nixos"
    "^nix-(?!search).*$"
  ];

  ignored = lib.strings.concatStringsSep "|" ignored_apps;

  dmenu_smart = pkgs.dmenu.overrideAttrs (old: {
    postPatch = ''
      cat <<EOF > dmenu_path
          #!$out/bin/sh

          IFS=:
          $out/bin/stest -flx \$PATH | sort -u | grep -vP "${ignored}"
      EOF
    '';
  });
in {
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = true;
        greeters.enso = {
          enable = true;
          blur = true;
        };
      };
    };
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    libinput.enable = true;
    xkbOptions =
      lib.strings.concatStringsSep "," [ "compose:ralt" "caps:none" ];
  };

  environment.systemPackages = with pkgs; [
    haskellPackages.xmobar
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
    dmenu_smart
  ];

  services.dbus.enable = true;
  programs.kdeconnect.enable = true;
}

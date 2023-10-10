{ lib, pkgs, ... }:
let
  ignored_apps = [ "google-chrome.*" ];

  ignored = lib.strings.concatStringsSep "|" ignored_apps;

  dmenu_smart = pkgs.dmenu.overrideAttrs (old: {
    postPatch = ''
      cat <<EOF > dmenu_path
          #!$out/bin/sh

          IFS=:
          $out/bin/stest -flx \$PATH | sort -u | grep -v "${ignored}"
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

{ pkgs, ... }: {
  imports = [
    ./xmonad.nix
    ./xmobar.nix
    ./picom.nix
    ./dunst.nix
    ./wallpaper.nix
    ./osd.nix
  ];

  home.packages = with pkgs; [
    feh
    autorandr
    pwvucontrol
    (alias "screenshot" "${escrotum}/bin/escrotum --select --clipboard")
    nerd-fonts.roboto-mono
  ];

  fonts.fontconfig.enable = true;

  services.batsignal.enable = true;

  systemd.user.services."dock-settings" = {
    Service = {
      ExecStart = pkgs.writers.writeBash "dock-set" ''
        udevadm monitor --environment --udev | while read -r line; do
          if echo "$line" | grep -q "change"; then
            while read -r detail; do
              if echo "$detail" | grep -q "ID_INPUT_KEYBOARD=1"; then
                  ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option compose:ralt
                  ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option caps:none
                  break
              fi
            done
          fi
        done
      '';
      Restart = "on-failure";
      RestartSec = 2;
    };

    Unit = {
      Description = "Dock setting adjuster";
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}

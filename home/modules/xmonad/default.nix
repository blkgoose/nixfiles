{ pkgs, ... }: {
  imports =
    [ ./xmonad.nix ./xmobar.nix ./picom.nix ./dunst.nix ./wallpaper.nix ];

  home.packages = with pkgs; [ autorandr pavucontrol ];

  systemd.user.services."keyboard-configurations" = {
    Service = {
      ExecStart = pkgs.writers.writeBash "keyconfig" ''
        ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option compose:ralt
        ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option caps:none
      '';
    };
    Unit = {
      Description = "Configures setxkbmap";
      After = "graphical-session.target";
      PartOf = "graphical-session.target";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}

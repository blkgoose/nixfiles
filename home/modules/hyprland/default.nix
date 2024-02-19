{ pkgs, ... }: {
  imports = [ ./hyprland.nix ./waybar.nix ./hyprpaper.nix ];

  home.packages = with pkgs; [ swayidle ];
}

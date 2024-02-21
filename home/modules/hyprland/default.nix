{ pkgs, ... }: {
  imports = [ ./hyprland.nix ./waybar.nix ./hyprpaper.nix ./swayidle.nix ];

  home.packages = with pkgs; [ swayidle ];
}

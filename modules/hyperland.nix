{ pkgs, ... }: {
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [ wlr-randr waybar ];
}

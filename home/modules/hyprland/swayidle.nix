{ ... }: {
  home.file.".config/swayidle/config".text = ''
    timeout 300 'swaylock -f'
    timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'
    timeout 3600 'systemctl suspend' resume 'hyprctl dispatch dpms on'
  '';
}

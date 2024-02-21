{ ... }: {
  home.file.".config/swayidle/config".text = ''
    timeout 600 'systemctl suspend' resume 'hyprctl dispatch dpms on'
  '';
}

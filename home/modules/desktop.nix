{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    spotify
    gimp
    (alias "bambu-studio" "${(nixGL unstable.bambu-studio)}/bin/bambu-studio")
    beekeeper-studio
    zoom
    (alias "chrome" "${(nixGL google-chrome)}/bin/google-chrome-stable")
    (alias "discord" "${(nixGL legcord)}/bin/legcord")
    pwvucontrol
    htop
  ];

  services.kdeconnect.enable = true;

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  systemd.user.services.rclone-gdrive = {
    Unit = { Description = "Mount Google Drive"; };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScript "gdrive-clone" ''
        folder="${config.home.homeDirectory}/gdrive"
        umount "$folder" || true
        mkdir -p "$folder"
        ${pkgs.rclone}/bin/rclone mount drive: "$folder"
      ''}";
      ExecStop = "${pkgs.writeShellScript "gdrive-umount" ''
        folder="${config.home.homeDirectory}/gdrive"
        umount "$folder" || true
        rmdir "$folder" || true
      ''}";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install = { WantedBy = [ "default.target" ]; };
  };
}

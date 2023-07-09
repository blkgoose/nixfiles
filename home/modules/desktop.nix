{ pkgs, ... }: {
  home.packages = with pkgs; [
    discord
    google-chrome
    slack
    spotify
    telegram-desktop
    whatsapp-for-linux
  ];
}

{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ lutris stremio ];
  programs.steam.enable = true;
}

{ pkgs, lib, ... }: {
  imports = [ ../users/prima.nix ];

  # overrides because ubuntu sucks
  programs.alacritty.package = with pkgs; nixGL alacritty;
  systemd.user.services.picom.Service.ExecStart = with pkgs;
    lib.mkForce "${(nixGL picom)}/bin/picom";

  xsession.enable = true;
  xsession.initExtra = ''
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option compose:ralt
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option caps:none
  '';

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [ nerdfonts docker ];

  # adds docker service, link it with `ln -s ~/.nix-profile/bin/docker-service /etc/systemd/system/docker.service` and enable it
  home.file.".local/bin/docker-service".source =
    pkgs.writeText "docker.service" ''
      [Service]
      Type=notify
      ExecStart=/home/alessiobiancone/.nix-profile/bin/dockerd
      Description=Runs docker daemon

      [Unit]
      After=network.target

      [Install]
      WantedBy=multi-user.target
    '';
}

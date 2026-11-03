{ pkgs, ... }: {
  home.packages = with pkgs; [ swayidle ];

  home.file.".config/swayidle/config".text = ''
    idlehint 600
  '';
}

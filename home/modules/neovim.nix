{ pkgs, lib, dots, config, ... }:
{
  home.file.".config/nvim" = {
    source = "${dots}/nvim";
    recursive = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      gcc
      gnumake
    ];
  };
}

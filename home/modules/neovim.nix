{ pkgs, lib, dots, config, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      gcc
      gnumake
    ];
  };

  home.file.".config/nvim" = {
    source = "${dots}/nvim";
    recursive = true;
  };
}

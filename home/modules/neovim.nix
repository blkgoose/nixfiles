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

  xdg.configFile = {
    "nvim" = {
      source = "${dots}/nvim";
      recursive = true;
    };
  };
}

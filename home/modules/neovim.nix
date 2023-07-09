{ pkgs, lib, dots, config, ... }:
{
  xdg.configFile."nvim/init.lua".source = "${dots}/nvim/init.lua";
  xdg.configFile."nvim/lua/".source = "${dots}/nvim/lua/";

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

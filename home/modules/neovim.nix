{ pkgs, lib, dots, config, ... }:
{
  xdg.configFile."nvim/init.lua".source = "${dots}/nvim/init.lua";
  xdg.configFile."nvim/lua/config".source = "${dots}/nvim/lua/config";
  xdg.configFile."nvim/lua/palette.lua".source = "${dots}/nvim/lua/palette.lua";
  xdg.configFile."nvim/lua/plugins.lua".source = "${dots}/nvim/lua/plugins.lua";
  xdg.configFile."nvim/lua/utils.lua".source = "${dots}/nvim/lua/utils.lua";

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

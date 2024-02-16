{ ... }: {
  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua/".source = ./lua;

  home.sessionVariables = { EDITOR = "vim"; };
}

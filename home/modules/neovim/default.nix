{ pkgs, ... }: {
  xdg.configFile."nvim/init.lua".source = ./init.lua;
  xdg.configFile."nvim/lua/".source = ./lua;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [ gcc gnumake ];
    defaultEditor = true;
  };
}

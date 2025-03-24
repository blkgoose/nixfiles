{ secret_dots, ... }: {
  xdg.configFile = {
    "saint-peter.json".source = "${secret_dots}/saint-peter/saint-peter.json";
  };

  # hack to make the config file available for devcontainer that doesn't have access to symlink
  home.file.".ssh/config_link" = {
    text = ''
      Host github.com
         HostName github.com
         User git
         IdentityFile ~/.ssh/SAINT_PETER_GIT_KEY
    '';
    onChange = ''
      cp ~/.ssh/config_link ~/.ssh/config
    '';
  };

}

{ secret_dots, ... }: {
  xdg.configFile = {
    "saint-peter.json".source = "${secret_dots}/saint-peter/saint-peter.json";
  };

  home.file.".ssh/config".source = ''
    Host github.com
       HostName github.com
       User git
       IdentityFile ~/.ssh/SAINT_PETER_GIT_KEY
  '';
}

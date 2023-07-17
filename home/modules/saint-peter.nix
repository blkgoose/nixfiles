{ secret_dots, ... }: {
  xdg.configFile = {
    "saint-peter.json".source = "${secret_dots}/saint-peter/saint-peter.json";
  };
}

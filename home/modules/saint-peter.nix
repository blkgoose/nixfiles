{ secrets, ... }: {
  xdg.configFile = {
    "saint-peter.json".source = "${secrets}/saint-peter/saint-peter.json";
  };
}

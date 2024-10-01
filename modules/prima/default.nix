{ prima-nix, secret_dots, ... }: {
  imports = [ ./warp prima-nix.nixosModules.default ];

  prima.crowdstrike-falcon = {
    enable = true;
    cid = (builtins.readFile "${secret_dots}/crowdstrike_cid");
  };
}

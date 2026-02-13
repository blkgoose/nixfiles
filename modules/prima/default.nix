{ prima-nix, secrets, ... }: {
  imports = [ ./warp prima-nix.nixosModules.default ];

  prima.crowdstrike-falcon = {
    enable = true;
    cid = (builtins.readFile "${secrets}/crowdstrike_cid");
  };
}

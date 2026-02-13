{ ... }:
let
  dropContext = builtins.unsafeDiscardStringContext;

  toNetConf = confFile:
    let
      fileName = dropContext (builtins.baseNameOf confFile);
      fileName' = "NetworkManager/system-connections/" + fileName;
    in {
      name = fileName';
      value = {
        source = "${../../secrets}/network-manager/${fileName}";
        mode = "0600";
      };
    };

  nmConfigs =
    builtins.attrNames (builtins.readDir "${../../secrets}/network-manager/");
in {
  environment.etc = builtins.listToAttrs (builtins.map toNetConf nmConfigs);
}

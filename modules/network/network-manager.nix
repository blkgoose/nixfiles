{ secret_dots, ... }:
let
  dropContext = builtins.unsafeDiscardStringContext;

  toNetConf = confFile:
    let
      fileName = dropContext (builtins.baseNameOf confFile);
      fileName' = "NetworkManager/system-connections/" + fileName;
    in {
      name = fileName';
      value = {
        source = "${secret_dots}/network-manager/${fileName}";
        mode = "0600";
      };
    };

  nmConfigs =
    builtins.attrNames (builtins.readDir "${secret_dots}/network-manager/");
in {
  environment.etc = builtins.listToAttrs (builtins.map toNetConf nmConfigs);
}

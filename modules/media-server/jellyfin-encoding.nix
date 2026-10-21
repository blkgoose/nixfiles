{ pkgs, ... }:
let
  settings = {
    HardwareAccelerationType = "qsv";
    QsvDevice = "/dev/dri/renderD128";
    EnableTonemapping = "true";
    EnableHardwareEncoding = "true";
  };

  hwDecodingCodecs = [
    "h264"
    "hevc"
    "mpeg2video"
    "vc1"
    "vp9"
    "av1"
  ];

  xml = "${pkgs.xmlstarlet}/bin/xmlstarlet";

  setters = builtins.concatStringsSep " " (
    pkgs.lib.mapAttrsToList (k: v: "-u '/EncodingOptions/${k}' -v '${v}'") settings
  );

  codecs = builtins.concatStringsSep " " (
    map (c: "-s '/EncodingOptions/HardwareDecodingCodecs' -t elem -n string -v '${c}'") hwDecodingCodecs
  );

  patch = pkgs.writeShellScript "jellyfin-encoding-patch" ''
    f=/etc/arr/config/jellyfin/encoding.xml
    [ -f "$f" ] || exit 0
    ${xml} ed -L ${setters} -d '/EncodingOptions/HardwareDecodingCodecs/string' ${codecs} "$f"
    chown 1000:1000 "$f"
  '';
in
{
  systemd.services.arr-stack = {
    preStart = "${patch}";
    restartTriggers = [ patch ];
  };
}

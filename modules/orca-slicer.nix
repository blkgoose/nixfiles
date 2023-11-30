{ pkgs, ... }:
let
  version = "1.8.0";
  name = "OrcaSlicer_Linux_V${version}";
in {
  environment.systemPackages = [
    (pkgs.appimageTools.wrapType2 {
      inherit version;
      name = "orca-slicer";

      src = pkgs.fetchurl {
        url =
          "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/${name}.AppImage";
        hash = "sha256-neKWYzGbGed9awMoBQEwwZJKaeaV+5fdjM1MphjWkUg=";
      };

      profile = ''
        export LC_ALL=C.UTF-8
      '';

      extraPkgs = pkgs:
        (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs) ++ ([
          pkgs.webkitgtk
          pkgs.gst_all_1.gstreamer
          pkgs.gst_all_1.gst-libav
          pkgs.gst_all_1.gst-plugins-bad
        ]);
    })
  ];
}

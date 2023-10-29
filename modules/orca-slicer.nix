{ pkgs, ... }:
let
  version = "1.7.0";
  name = "OrcaSlicer_Linux_V${version}";
in {
  environment.systemPackages = [
    (pkgs.appimageTools.wrapType2 {
      inherit version;
      name = "orca-slicer";
      src = pkgs.fetchurl {
        url =
          "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/${name}.AppImage";
        hash = "sha256-5Ag+pZBsOULp2Kk0KVG/P2ZQ/UVZm7zJZ4B2eXNeS50=";
      };
      extraPkgs = pkgs: with pkgs; [ webkitgtk ];
    })
  ];
}

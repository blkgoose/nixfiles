{ pkgs, secrets, ... }:
let
  saint-peter = pkgs.rustPlatform.buildRustPackage rec {
    pname = "saint-peter";
    version = "1.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "blkgoose";
      repo = "saint-peter";
      rev = "v${version}";
      hash = "sha256-FTvLmGpc5kJsrEn9w/Dq3a5O8RH/Kg+2/WyOae5BCC8=";
    };

    cargoLock.lockFile = "${src}/Cargo.lock";

    nativeBuildInputs = [ pkgs.perl ];

    meta.mainProgram = "saint-peter";
  };
in
{
  home.packages = [ saint-peter ];

  xdg.configFile = {
    "saint-peter.json".source = "${secrets}/saint-peter/saint-peter.json";
  };
}

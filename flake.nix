{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    osd = {
      url = "github:blkgoose/osd-rs/feat/restart-on-failure";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms.url = "github:AvengeMedia/DankMaterialShell/stable";

    nix-optional-modules.url = "github:danielefongo/nix-optional-modules";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      system-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        config.permittedInsecurePackages = [
          "beekeeper-studio-5.3.4" # Electron version 31 is EOL
          "qtwebengine-5.15.19"
        ];

        overlays = [
          (self: super: {
            unstable = import inputs.nixpkgs-unstable {
              inherit system;

              config.allowUnfree = true;
            };
          })

          (self: super: {
            system-manager = inputs.system-manager.packages.${system}.default;
          })

          (self: super: {
            orca-slicer =
              let
                pname = "orca-slicer";
                version = "2.4.2";
                src = self.fetchurl {
                  url = "https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v2.4.2/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.4.2.AppImage";
                  hash = "sha256-0S+4yOrBrs0t+2N3rNSPmU+PpDntUpL6Uy3YKIDwKf0=";
                };
                contents = self.appimageTools.extract { inherit pname version src; };
              in
              self.appimageTools.wrapType2 {
                inherit pname version src;
                extraInstallCommands = ''
                  install -Dm444 ${contents}/com.orcaslicer.OrcaSlicer.desktop $out/share/applications/orca-slicer.desktop
                  substituteInPlace $out/share/applications/orca-slicer.desktop --replace-fail "Exec=AppRun" "Exec=orca-slicer"
                  install -Dm444 ${contents}/OrcaSlicer.png $out/share/pixmaps/OrcaSlicer.png
                '';
                extraPkgs = pkgs: [
                  pkgs.webkitgtk_4_1
                  pkgs.libsoup_3
                ];
              };
          })

          (self: super: {
            alias =
              name: command:
              pkgs.writeShellApplication {
                inherit name;
                text = ''
                  ${command} "$@"
                '';
              };

            appAlias =
              name: package:
              {
                params ? "",
                copy ? package,
              }:
              self.symlinkJoin {
                inherit name;
                paths = [ (self.alias name "${self.lib.getExe package} ${params}") ];
                postBuild = ''
                  test -d ${copy}/share/applications
                  mkdir -p $out/share/applications
                  for dir in icons pixmaps; do
                    if [ -d ${copy}/share/$dir ]; then
                      ln -s ${copy}/share/$dir $out/share/$dir
                    fi
                  done
                  for f in ${copy}/share/applications/*.desktop; do
                    sed \
                      -e '/^Name\[/d' \
                      -e '/^DBusActivatable=/d' \
                      -e 's|^Name=.*|Name=${
                        self.lib.toUpper (builtins.substring 0 1 name)
                      }${builtins.substring 1 (-1) name}|' \
                      -e 's|^Exec=[^ ]*|Exec=${name}|' \
                      "$f" > $out/share/applications/$(basename "$f")
                  done
                '';
              };

            secret = path: builtins.head (builtins.split "\n" (builtins.readFile "${secrets}/${path}"));
          })
        ];
      };

      secrets = ./secrets;

      lib = nixpkgs.lib;
      homeManager = {
        home-manager.extraSpecialArgs = inputs // {
          inherit system secrets;
        };
      };

      fmt = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    in
    {
      nixosConfigurations = {
        toaster = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = inputs // {
            inherit secrets;
          };
          modules = [
            ./systems/toaster
            homeManager
          ];
        };

        nas = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = inputs // {
            inherit secrets;
          };
          modules = [ ./systems/nas ];
        };
      };

      extLib = {
        homeModules = lib.mapAttrs' (
          name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (./home/modules + "/${name}")
        ) (builtins.readDir ./home/modules);

        inherit
          pkgs
          secrets
          system
          inputs
          ;

        mkHomeConfiguration =
          {
            modules,
            extraSpecialArgs ? { },
            pkgs ? pkgs,
          }:
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs modules;
            extraSpecialArgs =
              inputs
              // {
                inherit system secrets;
              }
              // extraSpecialArgs;
          };

        mkSystemConfig =
          {
            modules,
            extraSpecialArgs ? { },
          }:
          system-manager.lib.makeSystemConfig {
            inherit modules;
            extraSpecialArgs =
              inputs
              // {
                inherit system pkgs secrets;
              }
              // extraSpecialArgs;
          };
      };

      packages.${system}.orca-slicer = pkgs.orca-slicer;

      formatter.${system} = fmt;
    };
}

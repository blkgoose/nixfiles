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

    hyprland-guiutils = {
      url = "github:hyprwm/hyprland-guiutils";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
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
            # real GL wrapping is only needed on non-NixOS machines (the
            # work laptop flake overrides this with the real nixGL wrapper)
            nixGL = package: package;
          })

          (self: super: {
            system-manager = inputs.system-manager.packages.${system}.default;
          })

          (self: super: {
            hyprland-guiutils = inputs.hyprland-guiutils.packages.${system}.default;
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

      formatter.${system} = fmt;
      devShells.${system}.default = pkgs.mkShell {
        LD_LIBRARY_PATH = nixpkgs.lib.makeLibraryPath [ pkgs.openssl ];

        buildInputs = [
          fmt
          pkgs.nil
        ];
      };
    };
}

{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl.url = "github:nix-community/nixGL";

    suite_py.url = "suite_py";
    prima-nix.url = "prima-nix";

    secret_dots = {
      url = "git+file:./secret_dotfiles?shallow=1";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, system-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          inputs.suite_py.overlays.default
          (self: super: {
            unstable = import inputs.nixpkgs-unstable {
              inherit system;

              config.allowUnfree = true;
            };

          })

          inputs.nixgl.overlay
          (self: super: {
            nixGL = import ./home/lib/nixgl.nix { inherit pkgs; };
          })
        ];
      };

      lib = nixpkgs.lib;
      homeManager = {
        home-manager.extraSpecialArgs = inputs // { inherit system; };
      };
    in {
      formatter.x86_64-linux =
        nixpkgs.legacyPackages.x86_64-linux.nixfmt-classic;

      nixosConfigurations = {
        toaster = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = inputs;
          modules = [ ./systems/toaster homeManager ];
        };
      };

      homeConfigurations = {
        "alessiobiancone" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = inputs // { inherit system; };

          modules = [ ./home/systems/shittop.nix ];
        };
      };

      systemConfigs = {
        "shittop" = system-manager.lib.makeSystemConfig {
          extraSpecialArgs = inputs // {
            inherit system;
            inherit pkgs;
          };
          modules = [ ./systems/shittop ];
        };
      };
    };
}

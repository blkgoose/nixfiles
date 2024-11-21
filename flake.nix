{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-insomnia.url =
      "github:nixos/nixpkgs?rev=336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3";
    nixpkgs-discord.url =
      "github:nixos/nixpkgs?rev=b3a285628a6928f62cdf4d09f4e656f7ecbbcafb";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl.url = "github:nix-community/nixGL";

    suite_py.url = "suite_py";
    prima-nix.url = "prima-nix";
    prima-appsec = {
      url = "prima-appsec";
      flake = false;
    };

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
          inputs.nixgl.overlay
          (self: super: {
            unstable = import inputs.nixpkgs-unstable {
              inherit system;

              config.allowUnfree = true;
            };

          })

          (self: super: {
            insomnia =
              (import inputs.nixpkgs-insomnia { inherit system; }).insomnia;
            discord = (import inputs.nixpkgs-discord {
              inherit system;
              config.allowUnfree = true;
            }).discord;
          })

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

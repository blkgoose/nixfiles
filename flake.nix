{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-insomnia.url =
      "github:nixos/nixpkgs?rev=336eda0d07dc5e2be1f923990ad9fdb6bc8e28e3";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    suite_py.url = "suite_py";
    prima-nix.url = "prima-nix";

    secret_dots = {
      url = "git+file:./secret_dotfiles?shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware
    , suite_py, prima-nix, secret_dots, nixpkgs-insomnia, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          suite_py.overlays.default
          prima-nix.overlays.default
          (self: super: {
            unstable = import nixpkgs-unstable {
              inherit system;

              config.allowUnfree = true;
            };

            insomnia-old = import nixpkgs-insomnia { inherit system; };
          })
        ];
      };

      lib = nixpkgs.lib;
      homeManager = {
        home-manager.extraSpecialArgs = attrs // { inherit system; };
      };
    in {
      nixosConfigurations = {
        bjorn = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = attrs;
          modules = [ ./systems/bjorn homeManager ];
        };
        toaster = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = attrs;
          modules = [ ./systems/toaster homeManager ];
        };
      };
    };
}

{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    suite_py.url = "suite_py";
    prima-nix.url = "prima-nix";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";

    secret_dots = {
      url = "git+file:./secret_dotfiles?shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-flatpak, home-manager
    , nixos-hardware, suite_py, prima-nix, secret_dots, ... }@attrs:
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

              config = { allowUnfree = true; };
            };
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
          modules = [
            ./systems/bjorn
            homeManager
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };
      };
    };
}

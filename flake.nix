{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dots = {
      url = "git+file:./dotfiles?shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, dots, ... } @attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      homeManager = { home-manager.extraSpecialArgs = attrs // { inherit system; }; };
    in {
      nixosConfigurations = {
        vm = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = attrs;
          modules = [
            ./systems/vm
            homeManager
          ];
        };
      };
    };
}

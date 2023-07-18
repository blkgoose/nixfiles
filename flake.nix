{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    suite_py.url = "suite_py";

    secret_dots = {
      url = "git+file:./secret_dotfiles?shallow=1";
      flake = false;
    };
    dots = {
      url = "git+file:./dotfiles?shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, suite_py, dots
    , secret_dots, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [ suite_py.overlays.default ];
      };
      lib = nixpkgs.lib;
      homeManager = {
        home-manager.extraSpecialArgs = attrs // { inherit system; };
      };
    in {
      nixosConfigurations = {
        laptop = lib.nixosSystem {
          inherit system pkgs;

          specialArgs = attrs;
          modules = [ ./systems/laptop homeManager ];
        };
      };
    };
}

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

    nvim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    secret_dots = {
      url = "git+file:./secret_dotfiles?shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware
    , suite_py, prima-nix, secret_dots, nvim-nightly, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          suite_py.overlays.default
          prima-nix.overlays.default
          nvim-nightly.overlay
          (self: super: {
            unstable = import nixpkgs-unstable {
              inherit system;

              config.allowUnfree = true;
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

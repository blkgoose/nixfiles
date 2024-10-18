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

    # suite_py.url = "suite_py";
    # prima-nix.url = "prima-nix";
    # prima-appsec = {
    #   url = "prima-appsec";
    #   flake = false;
    # };

    # secret_dots = {
    #   url = "git+file:./secret_dotfiles?shallow=1";
    #   flake = false;
    # };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          # inputs.suite_py.overlays.default
          (self: super: {
            unstable = import inputs.nixpkgs-unstable {
              inherit system;

              config.allowUnfree = true;
            };

          })

          (self: super: {
            insomnia =
              (import inputs.nixpkgs-insomnia { inherit system; }).insomnia;
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

      homeConfigurations."alessiobiancone" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/users/prima.nix ];
      };
    };
}

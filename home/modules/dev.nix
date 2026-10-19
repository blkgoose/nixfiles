{ pkgs, nix-optional-modules, ... }:
let
  opts = nix-optional-modules.lib;
in
{
  imports = [
    (opts.module "dev" { } (_: {
      home.packages = with pkgs; [
        rustup
        nixfmt
        pkg-config
        openssl
        fh
        (alias "nh" ''sudo "$(which "${pkgs.nh}/bin/nh")"'')
        gh
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    }))

    (opts.module "dev.ai" { } (_: {
      home.packages = [ pkgs.unstable.claude-code ];
    }))
  ];
}

{
  description = "Nix flake of Fennel development tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      inherit (flake-utils.lib) eachDefaultSystem mkApp;
    in
    {
      overlays.default = import ./nix/overlay.nix;
    }
    // eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
            (import ./nix/ci.nix)
          ];
        };
      in
      rec {
        packages = {
          inherit (pkgs)
            fennel-lua5_1
            fennel-unstable-lua5_1

            fennel-lua5_2
            fennel-unstable-lua5_2

            fennel-lua5_3
            fennel-unstable-lua5_3

            fennel-lua5_4
            fennel-unstable-lua5_4

            fennel-luajit
            fennel-unstable-luajit

            faith
            faith-unstable

            fnlfmt
            fnlfmt-unstable

            fenneldoc

            fennel-ls
            fennel-ls-unstable
            ;
        };

        apps = builtins.mapAttrs (
          name: pkg:
          mkApp {
            drv = pkg;
            name = pkg.meta.mainProgram or pkg.pname;
          }
        ) packages;

        checks = packages // pkgs.checks;

        inherit (pkgs) devShells;
      }
    );
}

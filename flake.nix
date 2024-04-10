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
      fennel-tools = import ./nix/overlay.nix;
    in
    {
      overlays = rec {
        inherit fennel-tools;
        default = fennel-tools;
      };
    }
    // flake-utils.lib.eachDefaultSystem (
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

        apps =
          with flake-utils.lib;
          builtins.mapAttrs (
            name: pkg:
            mkApp {
              drv = pkg;
              name = pkg.meta.mainProgram or pkg.pname;
            }
          ) packages;

        checks = packages;

        devShells = rec {
          inherit (pkgs) ci-check-format ci-check-versions ci-update;
          default = pkgs.mkShell {
            inputsFrom = [
              ci-check-format
              ci-update
            ];
            packages = [ pkgs.fennel-ls-unstable ];
          };
        };
      }
    );
}

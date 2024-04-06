{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fennel-stable = {
      url = "sourcehut:~technomancy/fennel/1.4.2";
      flake = false;
    };
    fennel-unstable = {
      url = "sourcehut:~technomancy/fennel/main";
      flake = false;
    };
    fenneldoc = {
      url = "gitlab:andreyorst/fenneldoc/master";
      flake = false;
    };
    fnlfmt-stable = {
      url = "sourcehut:~technomancy/fnlfmt/0.3.1";
      flake = false;
    };
    fnlfmt-unstable = {
      url = "sourcehut:~technomancy/fnlfmt/main";
      flake = false;
    };
    faith-stable = {
      url = "sourcehut:~technomancy/faith/0.1.2";
      flake = false;
    };
    faith-unstable = {
      url = "sourcehut:~technomancy/faith/main";
      flake = false;
    };
    fennel-ls-stable = {
      url = "sourcehut:~xerool/fennel-ls/0.1.1";
      flake = false;
    };
    fennel-ls-unstable = {
      url = "sourcehut:~xerool/fennel-ls/main";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    let
      fennel-tools = import ./nix/overlay.nix { inherit inputs; };
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
          overlays = [ fennel-tools ];
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
          ci-check-format = pkgs.callPackage ./nix/pkgs/ci/check-format.nix {
            nixfmt = pkgs.nixfmt-rfc-style;
          };
          ci-check-versions = pkgs.callPackage ./nix/pkgs/ci/check-versions.nix { };
          default = ci-check-format;
        };
      }
    );
}

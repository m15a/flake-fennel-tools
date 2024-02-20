{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fennel-stable = {
      url = "sourcehut:~technomancy/fennel/1.4.0";
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
    fnlfmt = {
      url = "sourcehut:~technomancy/fnlfmt/main";
      flake = false;
    };
    faith = {
      url = "sourcehut:~technomancy/faith/main";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    let
      versions = import ./nix/versions.nix;

      fennel-tools = import ./nix/overlay.nix {
        inherit inputs versions;
      };
    in
    {
      overlays = rec {
        inherit fennel-tools;
        default = fennel-tools;
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fennel-tools ];
        };
      in
      rec {
        packages = {
          inherit (pkgs)
            fennel-luajit
            fennel-lua5_1
            fennel-lua5_2
            fennel-lua5_3
            fennel-lua5_4

            fennel-unstable-luajit
            fennel-unstable-lua5_1
            fennel-unstable-lua5_2
            fennel-unstable-lua5_3
            fennel-unstable-lua5_4

            faith
            fnlfmt
            fenneldoc;
        };

        apps = with flake-utils.lib;
          builtins.mapAttrs
            (name: _: mkApp { drv = self.packages.${system}.${name}; })
            packages;

        checks = packages;

        devShells = {
          ci-lint = pkgs.mkShell {
            buildInputs = with pkgs; [
              statix
              deadnix
              nixpkgs-fmt
              pre-commit
            ];
          };
          ci-versions = pkgs.mkShell {
            buildInputs = [
              pkgs.fennel-luajit
              (pkgs.fennel-unstable-luajit.overrideAttrs (_: {
                postInstall = ''
                  mv $out/bin/fennel $out/bin/fennel-unstable
                '';
              }))
              pkgs.fnlfmt
            ];
            FENNEL_PATH = "${pkgs.faith}/bin/?";
          };
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              statix
              deadnix
              nixpkgs-fmt
              pre-commit
            ];
          };
        };
      }));
}

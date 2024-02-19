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
          fennel-stable-luajit = pkgs.fennel.stable.luajit;
          fennel-stable-lua5_1 = pkgs.fennel.stable.lua5_1;
          fennel-stable-lua5_2 = pkgs.fennel.stable.lua5_2;
          fennel-stable-lua5_3 = pkgs.fennel.stable.lua5_3;
          fennel-stable-lua5_4 = pkgs.fennel.stable.lua5_4;

          fennel-unstable-luajit = pkgs.fennel.unstable.luajit;
          fennel-unstable-lua5_1 = pkgs.fennel.unstable.lua5_1;
          fennel-unstable-lua5_2 = pkgs.fennel.unstable.lua5_2;
          fennel-unstable-lua5_3 = pkgs.fennel.unstable.lua5_3;
          fennel-unstable-lua5_4 = pkgs.fennel.unstable.lua5_4;

          faith-stable-luajit = pkgs.faith.stable.luajit;
          faith-stable-lua5_1 = pkgs.faith.stable.lua5_1;
          faith-stable-lua5_2 = pkgs.faith.stable.lua5_2;
          faith-stable-lua5_3 = pkgs.faith.stable.lua5_3;
          faith-stable-lua5_4 = pkgs.faith.stable.lua5_4;

          faith-unstable-luajit = pkgs.faith.unstable.luajit;
          faith-unstable-lua5_1 = pkgs.faith.unstable.lua5_1;
          faith-unstable-lua5_2 = pkgs.faith.unstable.lua5_2;
          faith-unstable-lua5_3 = pkgs.faith.unstable.lua5_3;
          faith-unstable-lua5_4 = pkgs.faith.unstable.lua5_4;

          inherit (pkgs) fnlfmt fenneldoc;
        };

        apps = with flake-utils.lib; rec {
          fennel-stable-luajit = mkApp {
            drv = self.packages.${system}.fennel-stable-luajit;
            name = "fennel";
          };
          fennel-stable-lua5_1 = mkApp {
            drv = self.packages.${system}.fennel-stable-lua5_1;
            name = "fennel";
          };
          fennel-stable-lua5_2 = mkApp {
            drv = self.packages.${system}.fennel-stable-lua5_2;
            name = "fennel";
          };
          fennel-stable-lua5_3 = mkApp {
            drv = self.packages.${system}.fennel-stable-lua5_3;
            name = "fennel";
          };
          fennel-stable-lua5_4 = mkApp {
            drv = self.packages.${system}.fennel-stable-lua5_4;
            name = "fennel";
          };
          fennel-unstable-luajit = mkApp {
            drv = self.packages.${system}.fennel-unstable-luajit;
            name = "fennel";
          };
          fennel-unstable-lua5_1 = mkApp {
            drv = self.packages.${system}.fennel-unstable-lua5_1;
            name = "fennel";
          };
          fennel-unstable-lua5_2 = mkApp {
            drv = self.packages.${system}.fennel-unstable-lua5_2;
            name = "fennel";
          };
          fennel-unstable-lua5_3 = mkApp {
            drv = self.packages.${system}.fennel-unstable-lua5_3;
            name = "fennel";
          };
          fennel-unstable-lua5_4 = mkApp {
            drv = self.packages.${system}.fennel-unstable-lua5_4;
            name = "fennel";
          };

          faith-stable-luajit = mkApp {
            drv = self.packages.${system}.faith-stable-luajit;
            name = "faith";
          };
          faith-stable-lua5_1 = mkApp {
            drv = self.packages.${system}.faith-stable-lua5_1;
            name = "faith";
          };
          faith-stable-lua5_2 = mkApp {
            drv = self.packages.${system}.faith-stable-lua5_2;
            name = "faith";
          };
          faith-stable-lua5_3 = mkApp {
            drv = self.packages.${system}.faith-stable-lua5_3;
            name = "faith";
          };
          faith-stable-lua5_4 = mkApp {
            drv = self.packages.${system}.faith-stable-lua5_4;
            name = "faith";
          };
          faith-unstable-luajit = mkApp {
            drv = self.packages.${system}.faith-unstable-luajit;
            name = "faith";
          };
          faith-unstable-lua5_1 = mkApp {
            drv = self.packages.${system}.faith-unstable-lua5_1;
            name = "faith";
          };
          faith-unstable-lua5_2 = mkApp {
            drv = self.packages.${system}.faith-unstable-lua5_2;
            name = "faith";
          };
          faith-unstable-lua5_3 = mkApp {
            drv = self.packages.${system}.faith-unstable-lua5_3;
            name = "faith";
          };
          faith-unstable-lua5_4 = mkApp {
            drv = self.packages.${system}.faith-unstable-lua5_4;
            name = "faith";
          };

          fnlfmt = mkApp {
            drv = self.packages.${system}.fnlfmt;
            name = "fnlfmt";
          };
          fenneldoc = mkApp {
            drv = self.packages.${system}.fenneldoc;
            name = "fenneldoc";
          };
        };

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
            FENNEL_PATH = "${pkgs.faith.stable.luajit}/bin/?";
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

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
      fennel-stable-version = "1.4.0";
      fennel-unstable-version = "1.4.1-dev";

      fennel-tools = import ./nix/overlay.nix {
        inherit inputs fennel-stable-version fennel-unstable-version;
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

        checks = packages;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            statix
            deadnix
            nixpkgs-fmt
            pre-commit
          ];
        };
      }));
}

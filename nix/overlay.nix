final: prev:

let
  fennelVariants = [
    "stable"
    "unstable"
  ];

  luaVariants = [
    "luajit"
    "lua5_1"
    "lua5_2"
    "lua5_3"
    "lua5_4"
  ];

  inherit (prev) lib;
  inherit (lib.strings) fromJSON;

  stablePkgsInfo = import ./stable-packages.nix;

  unstablePkgsInfo =
    let
      unstablePkgsVersions = fromJSON (lib.readFile ../data/unstable-versions.json);

      repoToAttrset = x: {
        name = x.repo;
        value = x // {
          version = unstablePkgsVersions.${x.repo};
        };
      };

      data = fromJSON (lib.readFile ../data/unstable-packages.json);
    in
    builtins.listToAttrs (map repoToAttrset data);

  buildFennel =
    { fennelVariant, luaVariant }:
    {
      name =
        if fennelVariant == "stable" then
          "fennel-${luaVariant}"
        else
          "fennel-${fennelVariant}-${luaVariant}";
      value =
        let
          lua = final.${luaVariant};
          fennel = final.callPackage ./pkgs/fennel (
            {
              pkgInfo =
                if fennelVariant == "stable" then
                  stablePkgsInfo.fennel
                else
                  unstablePkgsInfo.fennel;
              inherit lua;
            }
            // lib.optionalAttrs (fennelVariant != "stable") { shortRev = true; }
          );
          withLuaPackages = pkgs: fennel.override { lua = lua.withPackages pkgs; };
        in
        fennel.overrideAttrs (old: {
          passthru = old.passthru // {
            inherit withLuaPackages;
          };
        });
    };

  buildPackageSet = { builder, args }: builtins.listToAttrs (map builder args);
in
buildPackageSet {
  builder = buildFennel;
  args = lib.cartesianProduct {
    fennelVariant = fennelVariants;
    luaVariant = luaVariants;
  };
}
// {
  faith = final.callPackage ./pkgs/faith { pkgInfo = stablePkgsInfo.faith; };
  faith-unstable = final.callPackage ./pkgs/faith {
    shortRev = true;
    pkgInfo = unstablePkgsInfo.faith;
  };

  fnlfmt = final.callPackage ./pkgs/fnlfmt {
    pkgInfo = stablePkgsInfo.fnlfmt;
    lua = final.luajit;
  };
  fnlfmt-unstable = final.callPackage ./pkgs/fnlfmt {
    shortRev = true;
    pkgInfo = unstablePkgsInfo.fnlfmt;
    lua = final.luajit;
  };

  fenneldoc = final.callPackage ./pkgs/fenneldoc { lua = final.lua5_4; };

  fennel-ls = final.callPackage ./pkgs/fennel-ls {
    pkgInfo = stablePkgsInfo.fennel-ls;
    lua = final.lua5_4;
  };
  fennel-ls-unstable = final.callPackage ./pkgs/fennel-ls {
    shortRev = true;
    pkgInfo = unstablePkgsInfo.fennel-ls;
    lua = final.lua5_4;
  };
}

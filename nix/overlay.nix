{ inputs }:

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

  inherit (prev.lib)
    strings readFile optionalAttrs cartesianProductOfSets;

  packageVersions = strings.fromJSON (readFile ./pkgs/versions.json);

  buildFennel = { fennelVariant, luaVariant }: {
    name =
      if fennelVariant == "stable"
      then "fennel-${luaVariant}"
      else "fennel-${fennelVariant}-${luaVariant}";
    value = final.callPackage ./pkgs/fennel ({
      version = packageVersions."fennel-${fennelVariant}";
      src = inputs."fennel-${fennelVariant}";
      lua = final.${luaVariant};
    } // (optionalAttrs (fennelVariant != "stable") {
      inherit (inputs."fennel-${fennelVariant}") shortRev;
    }));
  };

  buildPackageSet = { builder, args }:
    builtins.listToAttrs (map builder args);
in

(buildPackageSet {
  builder = buildFennel;
  args = cartesianProductOfSets {
    fennelVariant = fennelVariants;
    luaVariant = luaVariants;
  };
}) // {
  faith = final.callPackage ./pkgs/faith {
    version = packageVersions.faith-stable;
    src = inputs.faith-stable;
  };
  faith-unstable = final.callPackage ./pkgs/faith {
    version = packageVersions.faith-unstable;
    inherit (inputs.faith-unstable) shortRev;
    src = inputs.faith-unstable;
  };
  fnlfmt = final.callPackage ./pkgs/fnlfmt {
    version = packageVersions.fnlfmt-stable;
    src = inputs.fnlfmt-stable;
    lua = final.luajit;
  };
  fnlfmt-unstable = final.callPackage ./pkgs/fnlfmt {
    version = packageVersions.fnlfmt-unstable;
    inherit (inputs.fnlfmt-unstable) shortRev;
    src = inputs.fnlfmt-unstable;
    lua = final.luajit;
  };
  fenneldoc = final.callPackage ./pkgs/fenneldoc {
    version = packageVersions.fenneldoc;
    inherit (inputs.fenneldoc) shortRev;
    src = inputs.fenneldoc;
    lua = final.lua5_4;
  };
  fennel-ls = final.callPackage ./pkgs/fennel-ls {
    version = packageVersions.fennel-ls-stable;
    src = inputs.fennel-ls-stable;
    lua = final.lua5_4;
  };
  fennel-ls-unstable = final.callPackage ./pkgs/fennel-ls {
    version = inputs.fennel-ls-unstable.lastModifiedDate;
    src = inputs.fennel-ls-unstable;
    lua = final.lua5_4;
  };
}

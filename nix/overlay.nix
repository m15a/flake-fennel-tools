{ inputs, versions }:

final: prev:

let
  fennelVersions = [
    "stable"
    "unstable"
  ];

  luaVersions = [
    "luajit"
    "lua5_1"
    "lua5_2"
    "lua5_3"
    "lua5_4"
  ];

  buildFennel = { fennelVersion, luaVersion }: {
    name =
      if fennelVersion == "stable"
      then "fennel-${luaVersion}"
      else "fennel-${fennelVersion}-${luaVersion}";
    value = final.callPackage ./pkgs/fennel {
      version = versions."fennel-${fennelVersion}";
      src = inputs."fennel-${fennelVersion}";
      lua = final.${luaVersion};
    };
  };

  buildPackageSet = { builder, args }:
    builtins.listToAttrs (map builder args);
in

(buildPackageSet {
  builder = buildFennel;
  args = prev.lib.cartesianProductOfSets {
    fennelVersion = fennelVersions;
    luaVersion = luaVersions;
  };
}) // {
  faith = final.callPackage ./pkgs/faith {
    version = versions.faith-stable;
    src = inputs.faith-stable;
  };
  faith-unstable = final.callPackage ./pkgs/faith {
    version = versions.faith-unstable;
    src = inputs.faith-unstable;
  };
  fnlfmt = final.callPackage ./pkgs/fnlfmt {
    version = versions.fnlfmt-stable;
    src = inputs.fnlfmt-stable;
    lua = final.luajit;
  };
  fnlfmt-unstable = final.callPackage ./pkgs/fnlfmt {
    version = versions.fnlfmt-unstable;
    src = inputs.fnlfmt-unstable;
    lua = final.luajit;
  };
  fenneldoc = final.callPackage ./pkgs/fenneldoc {
    version = versions.fenneldoc;
    src = inputs.fenneldoc;
    lua = final.lua5_4;
  };
}

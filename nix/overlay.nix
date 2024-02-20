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

  inherit (prev.lib) optionalString cartesianProductOfSets;

  buildFennel = { fennelVersion, luaVersion }: {
    name =
      if fennelVersion == "stable"
      then "fennel-${luaVersion}"
      else "fennel-${fennelVersion}-${luaVersion}";
    value = final.callPackage ./pkgs/fennel {
      version =
        versions."fennel-${fennelVersion}" +
        optionalString (fennelVersion != "stable")
          "-${inputs."fennel-${fennelVersion}".shortRev}";
      src = inputs."fennel-${fennelVersion}";
      lua = final.${luaVersion};
    };
  };

  buildPackageSet = { builder, args }:
    builtins.listToAttrs (map builder args);
in

(buildPackageSet {
  builder = buildFennel;
  args = cartesianProductOfSets {
    fennelVersion = fennelVersions;
    luaVersion = luaVersions;
  };
}) // {
  faith = final.callPackage ./pkgs/faith {
    version = versions.faith-stable;
    src = inputs.faith-stable;
  };
  faith-unstable = final.callPackage ./pkgs/faith {
    version =
      versions.faith-unstable +
      "-${inputs.faith-unstable.shortRev}";
    src = inputs.faith-unstable;
  };
  fnlfmt = final.callPackage ./pkgs/fnlfmt {
    version = versions.fnlfmt-stable;
    src = inputs.fnlfmt-stable;
    lua = final.luajit;
  };
  fnlfmt-unstable = final.callPackage ./pkgs/fnlfmt {
    version = versions.fnlfmt-unstable +
    "-${inputs.fnlfmt-unstable.shortRev}";
    src = inputs.fnlfmt-unstable;
    lua = final.luajit;
  };
  fenneldoc = final.callPackage ./pkgs/fenneldoc {
    version = versions.fenneldoc +
    "-${inputs.fenneldoc.shortRev}";
    src = inputs.fenneldoc;
    lua = final.lua5_4;
  };
}

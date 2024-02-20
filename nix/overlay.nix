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

  inherit (prev.lib) optionalAttrs cartesianProductOfSets;

  buildFennel = { fennelVersion, luaVersion }: {
    name =
      if fennelVersion == "stable"
      then "fennel-${luaVersion}"
      else "fennel-${fennelVersion}-${luaVersion}";
    value = final.callPackage ./pkgs/fennel ({
      version = versions."fennel-${fennelVersion}";
      src = inputs."fennel-${fennelVersion}";
      lua = final.${luaVersion};
    } // (optionalAttrs (fennelVersion != "stable") {
      inherit (inputs."fennel-${fennelVersion}") shortRev;
    }));
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
    version = versions.faith-unstable;
    inherit (inputs.faith-unstable) shortRev;
    src = inputs.faith-unstable;
  };
  fnlfmt = final.callPackage ./pkgs/fnlfmt {
    version = versions.fnlfmt-stable;
    src = inputs.fnlfmt-stable;
    lua = final.luajit;
  };
  fnlfmt-unstable = final.callPackage ./pkgs/fnlfmt {
    version = versions.fnlfmt-unstable;
    inherit (inputs.fnlfmt-unstable) shortRev;
    src = inputs.fnlfmt-unstable;
    lua = final.luajit;
  };
  fenneldoc = final.callPackage ./pkgs/fenneldoc {
    version = versions.fenneldoc;
    inherit (inputs.fenneldoc) shortRev;
    src = inputs.fenneldoc;
    lua = final.lua5_4;
  };
}

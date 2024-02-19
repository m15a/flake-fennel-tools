{ inputs, versions }:

final: prev:

let
  fennelWith = { version, src, lua }:
    final.callPackage ./pkgs/fennel {
      inherit version src lua;
    };

  faithWith = { version, fennel }:
    final.callPackage ./pkgs/faith {
      src = inputs.faith;
      inherit version fennel;
    };
in

{
  fennel = {
    stable = {
      luajit = fennelWith {
        version = versions.fennel-stable;
        src = inputs.fennel-stable;
        lua = final.luajit;
      };
      lua5_1 = fennelWith {
        version = versions.fennel-stable;
        src = inputs.fennel-stable;
        lua = final.lua5_1;
      };

      lua5_2 = fennelWith {
        version = versions.fennel-stable;
        src = inputs.fennel-stable;
        lua = final.lua5_2;
      };

      lua5_3 = fennelWith {
        version = versions.fennel-stable;
        src = inputs.fennel-stable;
        lua = final.lua5_3;
      };

      lua5_4 = fennelWith {
        version = versions.fennel-stable;
        src = inputs.fennel-stable;
        lua = final.lua5_4;
      };

    };
    unstable = {
      luajit = fennelWith {
        version = versions.fennel-unstable;
        src = inputs.fennel-unstable;
        lua = final.luajit;
      };
      lua5_1 = fennelWith {
        version = versions.fennel-unstable;
        src = inputs.fennel-unstable;
        lua = final.lua5_1;
      };
      lua5_2 = fennelWith {
        version = versions.fennel-unstable;
        src = inputs.fennel-unstable;
        lua = final.lua5_2;
      };
      lua5_3 = fennelWith {
        version = versions.fennel-unstable;
        src = inputs.fennel-unstable;
        lua = final.lua5_3;
      };
      lua5_4 = fennelWith {
        version = versions.fennel-unstable;
        src = inputs.fennel-unstable;
        lua = final.lua5_4;
      };
    };
  };

  faith = {
    stable = {
      luajit = faithWith {
        version = versions.faith;
        fennel = final.fennel.stable.luajit;
      };
      lua5_1 = faithWith {
        version = versions.faith;
        fennel = final.fennel.stable.lua5_1;
      };
      lua5_2 = faithWith {
        version = versions.faith;
        fennel = final.fennel.stable.lua5_2;
      };
      lua5_3 = faithWith {
        version = versions.faith;
        fennel = final.fennel.stable.lua5_3;
      };
      lua5_4 = faithWith {
        version = versions.faith;
        fennel = final.fennel.stable.lua5_4;
      };
    };
    unstable = {
      luajit = faithWith {
        version = versions.faith;
        fennel = final.fennel.unstable.luajit;
      };
      lua5_1 = faithWith {
        version = versions.faith;
        fennel = final.fennel.unstable.lua5_1;
      };
      lua5_2 = faithWith {
        version = versions.faith;
        fennel = final.fennel.unstable.lua5_2;
      };
      lua5_3 = faithWith {
        version = versions.faith;
        fennel = final.fennel.unstable.lua5_3;
      };
      lua5_4 = faithWith {
        version = versions.faith;
        fennel = final.fennel.unstable.lua5_4;
      };
    };
  };

  fnlfmt = final.callPackage ./pkgs/fnlfmt {
    version = versions.fnlfmt;
    src = inputs.fnlfmt;
    lua = final.luajit;
  };

  fenneldoc = final.callPackage ./pkgs/fenneldoc {
    version = versions.fenneldoc;
    src = inputs.fenneldoc;
    lua = final.lua5_4;
  };
}

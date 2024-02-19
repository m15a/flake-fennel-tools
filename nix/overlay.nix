{ inputs, fennel-stable-version, fennel-unstable-version }:

final: prev:

let
  fennelWith = { lua, version, src }:
    final.callPackage ./pkgs/fennel {
      inherit lua version src;
    };

  faithWith = { fennel }:
    final.callPackage ./pkgs/faith {
      src = inputs.faith;
      inherit fennel;
    };
in

{
  fennel = {
    stable = {
      luajit = fennelWith {
        lua = final.luajit;
        version = fennel-stable-version;
        src = inputs.fennel-stable;
      };
      lua5_1 = fennelWith {
        lua = final.lua5_1;
        version = fennel-stable-version;
        src = inputs.fennel-stable;
      };

      lua5_2 = fennelWith {
        lua = final.lua5_2;
        version = fennel-stable-version;
        src = inputs.fennel-stable;
      };

      lua5_3 = fennelWith {
        lua = final.lua5_3;
        version = fennel-stable-version;
        src = inputs.fennel-stable;
      };

      lua5_4 = fennelWith {
        lua = final.lua5_4;
        version = fennel-stable-version;
        src = inputs.fennel-stable;
      };

    };
    unstable = {
      luajit = fennelWith {
        lua = final.luajit;
        version = fennel-unstable-version;
        src = inputs.fennel-unstable;
      };
      lua5_1 = fennelWith {
        lua = final.lua5_1;
        version = fennel-unstable-version;
        src = inputs.fennel-unstable;
      };
      lua5_2 = fennelWith {
        lua = final.lua5_2;
        version = fennel-unstable-version;
        src = inputs.fennel-unstable;
      };
      lua5_3 = fennelWith {
        lua = final.lua5_3;
        version = fennel-unstable-version;
        src = inputs.fennel-unstable;
      };
      lua5_4 = fennelWith {
        lua = final.lua5_4;
        version = fennel-unstable-version;
        src = inputs.fennel-unstable;
      };
    };
  };

  faith = {
    stable = {
      luajit = faithWith {
        fennel = final.fennel.stable.luajit;
      };
      lua5_1 = faithWith {
        fennel = final.fennel.stable.lua5_1;
      };
      lua5_2 = faithWith {
        fennel = final.fennel.stable.lua5_2;
      };
      lua5_3 = faithWith {
        fennel = final.fennel.stable.lua5_3;
      };
      lua5_4 = faithWith {
        fennel = final.fennel.stable.lua5_4;
      };
    };
    unstable = {
      luajit = faithWith {
        fennel = final.fennel.unstable.luajit;
      };
      lua5_1 = faithWith {
        fennel = final.fennel.unstable.lua5_1;
      };
      lua5_2 = faithWith {
        fennel = final.fennel.unstable.lua5_2;
      };
      lua5_3 = faithWith {
        fennel = final.fennel.unstable.lua5_3;
      };
      lua5_4 = faithWith {
        fennel = final.fennel.unstable.lua5_4;
      };
    };
  };

  fnlfmt = final.callPackage ./pkgs/fnlfmt {
    src = inputs.fnlfmt;
    lua = final.luajit;
  };

  fenneldoc = final.callPackage ./pkgs/fenneldoc {
    src = inputs.fenneldoc;
    lua = final.lua5_4;
  };
}

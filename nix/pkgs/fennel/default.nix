{ version
, shortRev ? null
, src
, lua
, stdenv
, lib
, fetchpatch
, pandoc
}:

let
  out = stdenv.mkDerivation rec {
    pname = "fennel";
    inherit version src;

    nativeBuildInputs = [
      lua
    ];

    patches = [
      ./patches/man-inst.patch
    ];

    postPatch = with lib;
      let
        version' = strings.escapeRegex version;
      in
      optionalString (shortRev != null) ''
        # Append short commit hash to version string.
        sed -E -i src/fennel/utils.fnl \
            -e "s|(local version :)(${version'})(\))|\1${version}-${shortRev}\3|"
      '';

    makeFlags = [
      "PREFIX=$(out)"
    ];

    postBuild = ''
      patchShebangs .
    '';

    passthru = { inherit lua man; };

    meta = with lib; {
      description = "Lua Lisp Language";
      homepage = "https://fennel-lang.org/";
      license = licenses.mit;
      mainProgram = pname;
    };
  };

  man = stdenv.mkDerivation rec {
    inherit (out) pname version src;

    nativeBuildInputs = [
      out
      lua
      pandoc
    ];

    patches = with lib;
      out.patches ++
      optionals (versionOlder version "1.4.2") [
        (fetchpatch {
          name = "fix Makefile manpage installation";
          url = "https://git.sr.ht/~technomancy/fennel/commit/f0e341239b0bdbbc1aa5f2b715a3389e2ab07646.patch";
          hash = "sha256-/zWcpyb5qd8ffW0FSJsXXm0nq4xWWfdrDpI41+JZZ0E=";
        })
      ];

    postPatch = ''
      sed -E -i Makefile -e 's|\./fennel|fennel|'
    '';

    makeFlags = [
      "PREFIX=$(out)"
    ];

    buildFlags = [
      "man"
    ];

    installTargets = "install-man";

    inherit (out) meta;
  };
in

out

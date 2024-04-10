{
  shortRev ? false,
  pkgInfo,
  stdenv,
  lib,
  fetchurl,
  fetchpatch,
  lua,
  pandoc,
}:

let
  inherit (pkgInfo)
    version
    rev
    url
    sha256
    ;

  v' = lib.strings.escapeRegex version;
  v = version + lib.optionalString shortRev "-${lib.strings.substring 0 7 rev}";

  out = stdenv.mkDerivation rec {
    pname = "fennel";
    version = v;
    src = fetchurl { inherit url sha256; };

    buildInputs = [ lua ];

    patches = [ ./patches/man-inst.patch ];

    postPatch = lib.optionalString shortRev ''
      # Append short commit hash to version string.
      sed -E -i src/fennel/utils.fnl \
          -e 's|(local version :)(${v'})(\))|\1${v}\3|'
    '';

    makeFlags = [ "PREFIX=$(out)" ];

    passthru = {
      inherit lua man;
    };

    meta = with lib; {
      description = "The Fennel programming language";
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

    patches =
      out.patches
      ++ lib.optionals (lib.versionOlder version "1.4.2") [
        (fetchpatch {
          name = "fix Makefile manpage installation";
          url = "https://git.sr.ht/~technomancy/fennel/commit/f0e341239b0bdbbc1aa5f2b715a3389e2ab07646.patch";
          hash = "sha256-/zWcpyb5qd8ffW0FSJsXXm0nq4xWWfdrDpI41+JZZ0E=";
        })
      ];

    postPatch = ''
      sed -E -i Makefile -e 's|\./fennel|fennel|'
    '';

    makeFlags = [ "PREFIX=$(out)" ];

    buildFlags = [ "man" ];

    installTargets = "install-man";

    inherit (out) meta;
  };
in
out

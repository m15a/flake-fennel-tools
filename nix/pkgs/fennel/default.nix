{ version
, shortRev ? null
, src
, lua
, stdenv
, lib
, fetchpatch
, pandoc
}:

stdenv.mkDerivation rec {
  pname = "fennel";
  inherit version src;

  nativeBuildInputs = [
    lua
    pandoc
  ];

  patches = with lib;
    optionals (versionOlder version "1.4.2") [
      (fetchpatch {
        name = "fix Makefile manpage installation";
        url = "https://git.sr.ht/~technomancy/fennel/commit/f0e341239b0bdbbc1aa5f2b715a3389e2ab07646.patch";
        hash = "sha256-/zWcpyb5qd8ffW0FSJsXXm0nq4xWWfdrDpI41+JZZ0E=";
      })
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

  passthru = { inherit lua; };

  meta = with lib; {
    description = "Lua Lisp Language";
    homepage = "https://fennel-lang.org/";
    license = licenses.mit;
    mainProgram = pname;
  };
}

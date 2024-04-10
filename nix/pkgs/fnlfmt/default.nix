{
  shortRev ? false,
  pkgInfo,
  stdenv,
  lib,
  fetchurl,
  lua,
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
in
stdenv.mkDerivation rec {
  pname = "fnlfmt";
  version = v;
  src = fetchurl { inherit url sha256; };

  nativeBuildInputs = [ lua.pkgs.fennel ];
  buildInputs = [ lua ];

  postPatch =
    lib.optionalString shortRev ''
      # Append short commit hash to version string.
      sed -E -i fnlfmt.fnl \
          -e 's|(\{: fnlfmt : format-file :version :)(${v'})(\})|\1${v}\3|'
    ''
    + ''
      sed -i Makefile -e 's|./fennel|lua fennel|'
    '';

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A formatter for Fennel code";
    homepage = "https://git.sr.ht/~technomancy/fnlfmt";
    license = licenses.mit;
    mainProgram = pname;
  };
}

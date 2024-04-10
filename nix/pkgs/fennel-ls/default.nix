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

  # v' = lib.strings.escapeRegex version;
  v = version + lib.optionalString shortRev "-${lib.strings.substring 0 7 rev}";
in
stdenv.mkDerivation rec {
  pname = "fennel-ls";
  version = v;
  src = fetchurl { inherit url sha256; };

  postPatch = lib.optionalString shortRev ''
    # Append short commit hash to version string.
    sed -E -i src/fennel-ls/handlers.fnl \
        -e 's|(\{:name "fennel-ls" :version ")([^"]+)("\})|\1${v}\3|'
  '';

  buildInputs = [ lua ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Language Server for Fennel";
    homepage = "https://sr.ht/~xerool/fennel-ls/";
    license = licenses.mit;
    mainProgram = pname;
  };
}

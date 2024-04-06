{
  version,
  shortRev ? null,
  src,
  lua,
  stdenv,
  lib,
}:

let
  inherit (lib) optionalString;

  # v' = lib.strings.escapeRegex version;
  v = version + optionalString (shortRev != null) "-${shortRev}";
in
stdenv.mkDerivation rec {
  pname = "fennel-ls";
  version = v;
  inherit src;

  postPatch = optionalString (shortRev != null) ''
    # Append short commit hash to version string.
    sed -E -i src/fennel-ls/handlers.fnl \
        -e 's|(\{:name "fennel-ls" :version ")([^"]+)("\})|\1${v}\3|'
  '';

  buildInputs = [ lua ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A language server for fennel";
    homepage = "https://sr.ht/~xerool/fennel-ls/";
    license = licenses.mit;
    mainProgram = pname;
  };
}

{
  version,
  shortRev ? null,
  src,
  lua,
  stdenv,
  lib,
}:

let
  inherit (lib) optionalString strings;

  v' = strings.escapeRegex version;
  v = version + optionalString (shortRev != null) "-${shortRev}";
in
stdenv.mkDerivation rec {
  pname = "fnlfmt";
  version = v;
  inherit src;

  nativeBuildInputs = [ lua.pkgs.fennel ];
  buildInputs = [ lua ];

  postPatch =
    optionalString (shortRev != null) ''
      # Append short commit hash to version string.
      sed -E -i fnlfmt.fnl \
          -e 's|(\{: fnlfmt : format-file :version :)(${v'})(\})|\1${v}\3|'
    ''
    + ''
      sed -i Makefile -e 's|./fennel|lua fennel|'
    '';

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Format your Fennel!";
    homepage = "https://git.sr.ht/~technomancy/fnlfmt";
    license = licenses.mit;
    mainProgram = pname;
  };
}

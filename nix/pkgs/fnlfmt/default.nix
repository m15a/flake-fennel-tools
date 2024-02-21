{ version
, shortRev ? null
, src
, lua
, stdenv
, lib
}:

stdenv.mkDerivation rec {
  pname = "fnlfmt";
  inherit version src;

  nativeBuildInputs = [
    lua
    lua.pkgs.fennel
  ];

  postPatch = with lib;
    let
      version' = strings.escapeRegex version;
    in
    optionalString (shortRev != null) ''
      # Append short commit hash to version string.
      sed -E -i fnlfmt.fnl \
          -e "s|(\{: fnlfmt : format-file :version :)(${version'})(\})|\1${version}-${shortRev}\3|"
    '' + ''
      sed -i Makefile -e 's|./fennel|lua fennel|'
    '';

  makeFlags = [
    "PREFIX=$(out)"
  ];

  postBuild = ''
    patchShebangs .
  '';

  meta = with lib; {
    description = "Format your Fennel!";
    homepage = "https://git.sr.ht/~technomancy/fnlfmt";
    license = licenses.mit;
    mainProgram = pname;
  };
}

{ version, src, lua, stdenv, lib }:

stdenv.mkDerivation rec {
  pname = "fnlfmt";
  inherit version src;

  nativeBuildInputs = [
    lua
    lua.pkgs.fennel
  ];

  postPatch = ''
    # Append short commit hash to version string.
    sed -E -i fnlfmt.fnl \
        -e "s|(\{\s*:\s+fnlfmt\s+:\s+format-file\s+:version\s+:)([^\}]*)(\s*\})|\1${version}\3|"

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

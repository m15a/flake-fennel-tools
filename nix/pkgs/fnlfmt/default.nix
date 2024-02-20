{ version, src, lua, stdenv }:

stdenv.mkDerivation {
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
}

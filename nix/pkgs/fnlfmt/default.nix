{ version, src, lua, stdenv }:

stdenv.mkDerivation {
  pname = "fnlfmt";
  inherit version src;

  nativeBuildInputs = [
    lua
    lua.pkgs.fennel
  ];

  postPatch = ''
    sed -i Makefile -e 's|./fennel|lua fennel|'
  '';

  makeFlags = [
    "PREFIX=$(out)"
  ];

  postBuild = ''
    patchShebangs .
  '';
}

{ version, src, lua, stdenv }:

stdenv.mkDerivation rec {
  pname = "fenneldoc";
  inherit version src;

  nativeBuildInputs = [
    lua
    lua.pkgs.fennel
  ];

  postPatch = ''
    sed -i Makefile -e 's|\./fenneldoc|lua fenneldoc|'
  '';

  makeFlags = [
    "VERSION=${version}"
    "PREFIX=$(out)"
  ];

  postBuild = ''
    patchShebangs .
  '';
}

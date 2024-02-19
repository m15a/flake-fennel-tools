{ src, stdenv, lua }:

stdenv.mkDerivation rec {
  pname = "fenneldoc";
  version = "1.0.1-dev";

  inherit src;

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

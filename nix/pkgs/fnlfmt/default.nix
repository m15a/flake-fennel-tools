{ src, stdenv, lua }:

stdenv.mkDerivation {
  pname = "fnlfmt";
  version = "0.3.2-dev";

  inherit src;

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

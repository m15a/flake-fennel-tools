{ version, shortRev ? null, src, lua, stdenv, lib }:

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
    "VERSION=${version + lib.optionalString (shortRev != null) "-${shortRev}"}"
    "PREFIX=$(out)"
  ];

  postBuild = ''
    patchShebangs .
  '';

  meta = with lib; {
    description = "Tool for automatic documentation generation and validation for the Fennel language.";
    homepage = "https://gitlab.com/andreyorst/fenneldoc";
    license = licenses.mit;
    mainProgram = pname;
  };
}

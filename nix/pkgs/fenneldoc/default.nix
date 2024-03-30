{ version
, shortRev ? null
, src
, lua
, stdenv
, lib
}:

stdenv.mkDerivation rec {
  pname = "fenneldoc";
  inherit version src;

  nativeBuildInputs = [
    lua.pkgs.fennel
  ];
  buildInputs = [
    lua
  ];

  postPatch = ''
    sed -i Makefile -e 's|\./fenneldoc|lua fenneldoc|'
  '';

  makeFlags = with lib; [
    "VERSION=${version + optionalString (shortRev != null) "-${shortRev}"}"
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    description = "Tool for automatic documentation generation and validation for the Fennel language.";
    homepage = "https://gitlab.com/andreyorst/fenneldoc";
    license = licenses.mit;
    mainProgram = pname;
  };
}

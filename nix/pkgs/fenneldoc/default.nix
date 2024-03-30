{ version, shortRev ? null, src, lua, stdenv, lib }:

let v = version + lib.optionalString (shortRev != null) "-${shortRev}";

in stdenv.mkDerivation rec {
  pname = "fenneldoc";
  version = v;
  inherit src;

  nativeBuildInputs = [ lua.pkgs.fennel ];
  buildInputs = [ lua ];

  postPatch = ''
    sed -i Makefile -e 's|\./fenneldoc|lua fenneldoc|'
  '';

  makeFlags = [ "VERSION=${v}" "PREFIX=$(out)" ];

  meta = with lib; {
    description =
      "Tool for automatic documentation generation and validation for the Fennel language.";
    homepage = "https://gitlab.com/andreyorst/fenneldoc";
    license = licenses.mit;
    mainProgram = pname;
  };
}

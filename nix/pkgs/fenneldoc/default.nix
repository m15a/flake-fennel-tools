{
  stdenv,
  lib,
  fetchurl,
  lua,
}:

let
  version = "1.0.1-dev-" + lib.strings.substring 0 7 rev;
  rev = "7960056a31db6c28d0c2f3eb76e6bf88a90e436e";
in
stdenv.mkDerivation rec {
  pname = "fenneldoc";
  inherit version;
  src = fetchurl {
    url = "https://gitlab.com/andreyorst/fenneldoc/-/archive/${rev}.tar.gz";
    hash = "sha256-16OMCwJB9XA3DigbOZEnO8ZJ4O7W+JqIiZryIAd+cV0=";
  };

  nativeBuildInputs = [ lua.pkgs.fennel ];
  buildInputs = [ lua ];

  postPatch = ''
    sed -i Makefile -e 's|\./fenneldoc|lua fenneldoc|'
  '';

  makeFlags = [
    "VERSION=${version}"
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    description = "Tool for automatic documentation generation and validation for the Fennel language.";
    homepage = "https://gitlab.com/andreyorst/fenneldoc";
    license = licenses.mit;
    mainProgram = pname;
  };
}

{ version, src, stdenv, fennel }:

stdenv.mkDerivation {
  pname = "faith";
  inherit version src;

  nativeBuildInputs = [
    fennel
  ];

  buildPhase = ''
    mkdir bin
    {
        echo '#!/usr/bin/env fennel'
        cat faith.fnl
    } > bin/faith
    chmod +x bin/faith
    patchShebangs .
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 bin/faith -t $out/bin/
  '';

  passthru = { inherit fennel; };
}

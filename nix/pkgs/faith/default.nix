{ version, src, stdenv }:

stdenv.mkDerivation {
  pname = "faith";
  inherit version src;

  buildPhase = ''
    mkdir bin
    {
        echo '#!/usr/bin/env fennel'
        cat faith.fnl
    } > bin/faith
    chmod +x bin/faith
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 bin/faith -t $out/bin/
  '';
}

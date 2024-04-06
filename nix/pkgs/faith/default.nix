{
  version,
  shortRev ? null,
  src,
  stdenv,
  lib,
}:

let
  inherit (lib) optionalString strings;

  v' = strings.escapeRegex version;
  v = version + optionalString (shortRev != null) "-${shortRev}";
in
stdenv.mkDerivation rec {
  pname = "faith";
  version = v;
  inherit src;

  postPatch = optionalString (shortRev != null) ''
    # Append short commit hash to version string if any.
    sed -E -i faith.fnl \
        -e 's|(\{: run : skip :version ")(${v'})(")|\1${v}\3|'
  '';

  buildPhase = ''
    runHook preBuild
    mkdir bin
    {
        echo '#!/usr/bin/env fennel'
        cat faith.fnl
    } > bin/faith
    chmod +x bin/faith
    runHook postBuild
  '';

  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 bin/faith -t $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "The Fennel Advanced Interactive Test Helper.";
    homepage = "https://git.sr.ht/~technomancy/faith";
    license = licenses.mit;
    mainProgram = pname;
  };
}

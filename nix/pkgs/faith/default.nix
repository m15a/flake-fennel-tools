{
  shortRev ? false,
  pkgInfo,
  stdenv,
  lib,
  fetchurl,
}:

let
  inherit (pkgInfo)
    version
    rev
    url
    sha256
    ;

  v' = lib.strings.escapeRegex version;
  v = version + lib.optionalString shortRev "-${lib.strings.substring 0 7 rev}";
in
stdenv.mkDerivation rec {
  pname = "faith";
  version = v;
  src = fetchurl { inherit url sha256; };

  postPatch = lib.optionalString shortRev ''
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
    description = "A test library for Fennel";
    homepage = "https://git.sr.ht/~technomancy/faith";
    license = licenses.mit;
    mainProgram = pname;
  };
}

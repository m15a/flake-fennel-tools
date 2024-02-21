{ version
, shortRev ? null
, src
, stdenv
, lib
}:

stdenv.mkDerivation rec {
  pname = "faith";
  inherit version src;

  postPatch = with lib;
    let
      version' = strings.escapeRegex version;
    in
    optionalString (shortRev != null) ''
      # Append short commit hash to version string if any.
      sed -E -i faith.fnl \
          -e "s|(\{: run : skip :version \")(${version'})(\")|\1${version}-${shortRev}\3|"
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

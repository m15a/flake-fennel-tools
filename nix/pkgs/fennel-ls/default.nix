{ version
, src
, lua
, stdenv
, lib
}:

stdenv.mkDerivation rec {
  pname = "fennel-ls";
  inherit version src;

  nativeBuildInputs = [
    lua
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  postBuild = ''
    patchShebangs .
  '';

  meta = with lib; {
    description = "A language server for fennel";
    homepage = "https://sr.ht/~xerool/fennel-ls/";
    license = licenses.mit;
    mainProgram = pname;
  };
}

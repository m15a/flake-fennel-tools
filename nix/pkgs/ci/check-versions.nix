{
  mkShell,
  stdenv,
  fennel-unstable-luajit,
  faith-unstable,
  fnlfmt-unstable,
  fennel-ls-unstable,
  jq,
}:

let
  fennel-ls-unstable-changelog = stdenv.mkDerivation {
    name = fennel-ls-unstable.name + "-changelog";
    inherit (fennel-ls-unstable) src;
    dontConfigure = true;
    dontBuild = true;
    installPhase = "cp changelog.md $out";
    dontFixup = true;
  };
in

mkShell {
  packages = [
    fennel-unstable-luajit
    fnlfmt-unstable
    jq.bin
  ];
  FENNEL_PATH = "${faith-unstable}/bin/?";
  FENNEL_LS_UNSTABLE_CHANGELOG_PATH = fennel-ls-unstable-changelog;
}

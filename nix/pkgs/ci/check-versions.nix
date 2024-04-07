{
  mkShell,
  fennel,
  fennel-unstable,
  faith,
  faith-unstable,
  fnlfmt,
  fnlfmt-unstable,
  fenneldoc,
  fennel-ls,
  fennel-ls-unstable,
  jq,
}:

mkShell {
  packages = [
    fennel
    fennel-unstable
    fnlfmt
    fnlfmt-unstable
    jq.bin
  ];
  FENNEL_PATH = "${faith}/bin/?;${faith-unstable}/bin/?";
  FENNELDOC_PATH = "${fenneldoc}/bin/fenneldoc";
  FENNEL_LS_CHANGELOG_PATH = "${fennel-ls.src}/changelog.md";
  FENNEL_LS_UNSTABLE_CHANGELOG_PATH = "${fennel-ls-unstable.src}/changelog.md";
}

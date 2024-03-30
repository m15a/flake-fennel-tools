{ mkShell, fennel-luajit, fennel-unstable-luajit, faith, faith-unstable, fnlfmt
, fnlfmt-unstable, fenneldoc, fennel-ls, jq }:

let
  fennel-unstable-luajit' = fennel-unstable-luajit.overrideAttrs (_: {
    postInstall = ''
      mv $out/bin/fennel $out/bin/fennel-unstable
    '';
  });

  faith-unstable' = faith-unstable.overrideAttrs (_: {
    postInstall = ''
      mv $out/bin/faith $out/bin/faith-unstable
    '';
  });

  fnlfmt-unstable' = fnlfmt-unstable.overrideAttrs (_: {
    postInstall = ''
      mv $out/bin/fnlfmt $out/bin/fnlfmt-unstable
    '';
  });

in mkShell {
  packages =
    [ fennel-luajit fennel-unstable-luajit' fnlfmt fnlfmt-unstable' jq ];
  FENNEL_PATH = "${faith}/bin/?;${faith-unstable'}/bin/?";
  FENNELDOC_PATH = "${fenneldoc}/bin/fenneldoc";
  FENNEL_LS_CHANGELOG_PATH = "${fennel-ls.src}/changelog.md";
}

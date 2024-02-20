{ mkShell
, fennel-luajit
, fennel-unstable-luajit
, faith
, faith-unstable
, fnlfmt
, fnlfmt-unstable
, fenneldoc
}:

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
in

mkShell {
  buildInputs = [
    fennel-luajit
    fennel-unstable-luajit'
    fnlfmt
    fnlfmt-unstable'
  ];
  FENNEL_PATH = "${faith}/bin/?;${faith-unstable'}/bin/?";
  FENNELDOC_PATH = "${pkgs.fenneldoc}/bin/fenneldoc";
}

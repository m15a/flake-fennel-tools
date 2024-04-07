final: prev:

{
  ci-check-format = final.mkShell {
    packages = [
      final.statix
      final.deadnix
      final.nixfmt-rfc-style
      final.pre-commit
    ];
  };

  ci-check-versions = final.callPackage ./pkgs/ci/check-versions.nix {
    fennel = final.fennel-luajit;
    fennel-unstable = final.fennel-unstable-luajit.overrideAttrs (_: {
      postInstall = ''
        mv $out/bin/fennel $out/bin/fennel-unstable
      '';
    });
    faith-unstable = final.faith-unstable.overrideAttrs (_: {
      postInstall = ''
        mv $out/bin/faith $out/bin/faith-unstable
      '';
    });
    fnlfmt-unstable = final.fnlfmt-unstable.overrideAttrs (_: {
      postInstall = ''
        mv $out/bin/fnlfmt $out/bin/fnlfmt-unstable
      '';
    });
  };
}

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

  ci-check-versions = final.callPackage ./pkgs/ci/check-versions.nix { };

  ci-update = final.mkShell {
    packages = [
      final.nix
      final.jq.bin
      (final.fennel-luajit.withLuaPackages (
        ps: with ps; [
          http
          cjson
        ]
      ))
    ];
  };
}

{ mkShell
, statix
, deadnix
, nixpkgs-fmt
, pre-commit
}:

mkShell {
  packages = [
    statix
    deadnix
    nixpkgs-fmt
    pre-commit
  ];
}

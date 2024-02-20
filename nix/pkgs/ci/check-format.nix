{ mkShell
, statix
, deadnix
, nixpkgs-fmt
, pre-commit
}:

mkShell {
  buildInputs = [
    statix
    deadnix
    nixpkgs-fmt
    pre-commit
  ];
}

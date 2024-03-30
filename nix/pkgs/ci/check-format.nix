{ mkShell, statix, deadnix, nixfmt, pre-commit }:

mkShell { packages = [ statix deadnix nixfmt pre-commit ]; }

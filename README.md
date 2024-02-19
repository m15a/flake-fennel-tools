# flake-fennel-tools

Nix flake of Fennel development tools.

[![CI][1]][2]

## Description

There are a number of good development tools for [Fennel][3] programming:
[faith][4] for testing,
[fnlfmt][5] for formatting codes,
[fenneldoc][6] for generating documentation,
etc. (find more in [Fennel wiki][7]).

Some of these tools are missing in [nixpkgs][8][^1].
This repository aims to help Fennel developers using Nix by providing a [Nix flake][9],
which ships with Fennel development tools including those missing ones.

Moreover, this flake provides Fennel development version (i.e., `main` branch head).
So it would help testing your Fennel application/library against the cutting edge.

## Usage

### Overlay

Add the overlay provided by this flake to your `flake.nix`.
It could look like:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fennel-tools.url = "github:m15a/flake-fennel-tools";
  };
  outputs = { self, nixpkgs, flake-utils, fennel-tools, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fennel-tools.overlays.default ];
        };
      in
      {
        devShells.default =
          let
            fennel = pkgs.fennel-unstable-lua5_3;
          in
          pkgs.mkShell {
            buildInputs = [
              fennel
              pkgs.faith
              pkgs.fnlfmt
              pkgs.fenneldoc
            ] ++ (with fennel.lua.pkgs; [
              readline
            ]);
            FENNEL_PATH = "${pkgs.faith}/bin/?";
          };
      });
}
```

### Run applications on the fly

All packages that contain runnable applications are accessible via
`nix run` command. For example,

```console
$ nix run github:m15a/flake-fennel-tools#fennel-unstable-luajit
Welcome to Fennel 1.4.1-dev on LuaJIT 2.1.1693350652 Linux/x64!
Use ,help to see available commands.
Try installing readline via luarocks for a better repl experience.
>>
```

## License

[BSD 3-clause](LICENSE)

[1]: https://img.shields.io/github/actions/workflow/status/m15a/flake-fennel-tools/ci.yml?style=flat-square&logo=github&label=CI
[2]: https://github.com/m15a/flake-fennel-tools/actions/workflows/ci.yml
[3]: https://fennel-lang.org/
[4]: https://git.sr.ht/~technomancy/faith
[5]: https://git.sr.ht/~technomancy/fnlfmt
[6]: https://gitlab.com/andreyorst/fenneldoc
[7]: https://wiki.fennel-lang.org/#tools
[8]: https://github.com/NixOS/nixpkgs
[9]: https://nix.dev/concepts/flakes

[^1]: fnlfmt is available in nixpkgs as of Feb 2024.

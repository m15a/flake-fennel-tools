# flake-fennel-tools

Nix flake of Fennel development tools.

[![CI][1]][2]

## Description

There are a number of good development tools for [Fennel][3] programming:
[Faith][4] for testing,
[Fennel Format][5] for formatting codes,
[Fenneldoc][6] for generating documentation,
etc. (find more in [Fennel wiki][7]).

Some of these tools are missing in [nixpkgs][8][^1].
This repository aims to help Fennel developers using Nix by providing a [Nix flake][9],
which ships Fennel development tools including those missing ones.

Moreover, this flake provides Fennel development version (i.e., `main` branch head).
So it would help you test your Fennel application/library against the cutting edge.

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

## Available packages

### Fennel

This flake provides a number of Fennel variants, each being different in
Fennel stable version (`1.4.0` as of Feb 2024) or unstable version (`main`
branch head) and Lua version/implementation (LuaJIT or PUC Lua from `5.1`
to `5.4`). In total, $2 \times 5 = 10$ packages it has.

You can access them via attribute

```nix
pkgs.${system}.fennel-${FENNEL_VERSION}-${LUA_VERSION}
```

where `${FENNEL_VERSION}` is either `stable` or `unstable`
and `${LUA_VERSION}` is either one of `luajit`, `lua5_1`, `lua5_2`, ..., `lua5_4`.

### Faith

A testing library. Attribute:

```
pkgs.${system}.faith
```

In this flake, the package contains a runnable script of Faith,
`bin/faith`. The script begins with shebang line `#!/usr/bin/env fennel`,
thus enabling you to test your codes against different Fennel variants.

Don't forget to add the Faith script path to environment variable `$FENNEL_PATH`,
so that you can require Faith module in your test codes.
It could be set in `devShell`:

```nix
  pkgs.mkShell {
    buildInputs = [
      pkgs.fennel-unstable-lua5_2
      pkgs.faith
      ...
    ];
    FENNEL_PATH = "${pkgs.faith}/bin/?";
  };
  ...
```

or in shell (below is a Bash example):

```bash
export FENNEL_PATH="$(dirname $(which faith))/?"
```

For more information, take a look at the [Faith's repository][4].

### Fennel Format

A Fennel formatter. Attribute:

```
pkgs.${system}.fnlfmt
```

Nothing special has been done for Nix usage. Install it and format codes as usual.
For more information, read the document in [Fennel Format's repository][5].

### Fenneldoc

A Fennel API documentation generator. Attribute:

```
pkgs.${system}.fenneldoc
```

Again, once installed, you can just use it.
For more information, read the document in [Fenneldoc's repository][6].

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

[^1]: `fnlfmt` and `fennel-ls` are available in nixpkgs as of Feb 2024.

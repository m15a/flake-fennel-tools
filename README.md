# flake-fennel-tools

Nix flake of Fennel development tools.

[![CI][b1]][b2]
[![FlakeHub][b3]][b4]

[b1]: https://img.shields.io/github/actions/workflow/status/m15a/flake-fennel-tools/ci.yml?style=flat-square&logo=github&label=CI
[b2]: https://github.com/m15a/flake-fennel-tools/actions/workflows/ci.yml
[b3]: https://img.shields.io/endpoint?url=https://flakehub.com/f/m15a/flake-fennel-tools/badge
[b4]: https://flakehub.com/flake/m15a/flake-fennel-tools

## Description

There are a number of good development tools for [Fennel][1]
programming: [Faith][2] for testing, [Fennel Format][3] for formatting
code, [Fenneldoc][4] for generating documentation, [fennel-ls][5] for
linting, etc. (find more in [Fennel wiki][6]).

Some of these tools are missing in [nixpkgs][7][^1]. This flake aims to
help Fennel developers using Nix by providing Fennel development tools
*en masse*, including those missing ones.

Moreover, it provides Fennel development version (i.e., `main` branch),
which is updated once every day. It would help you test your Fennel
application/library against the cutting edge.

[1]: https://fennel-lang.org/
[2]: https://git.sr.ht/~technomancy/faith
[3]: https://git.sr.ht/~technomancy/fnlfmt
[4]: https://gitlab.com/andreyorst/fenneldoc
[5]: https://sr.ht/~xerool/fennel-ls/
[6]: https://wiki.fennel-lang.org/#tools
[7]: https://github.com/NixOS/nixpkgs

[^1]: `fnlfmt` and `fennel-ls` are available in nixpkgs as of Feb 2024.

## Usage

### Overlay

Add the default overlay of this flake to your `flake.nix`. It could
look like:

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
            FENNEL_MACRO_PATH = "./src/?.fnl;./src/?/init-macros.fnl";

            shellHook = ''
              # if you want to read man pages
              export MANPATH="${fennel.man}/share/man''${MANPATH:+:''${MANPATH}}"
            '';
          };
      });
}
```

### Run applications on the fly

Executable programs contained in the packages are accessible via
`nix run` command. For example,

```console
$ nix run github:m15a/flake-fennel-tools#fennel-unstable-luajit
Welcome to Fennel 1.4.2-dev-f0e3412 on LuaJIT 2.1.1693350652 Linux/x64!
Use ,help to see available commands.
Try installing readline via luarocks for a better repl experience.
>>
```

## Notes on each package

### Fennel

This flake exposes a number of Fennel variants, each being different in
Fennel version, stable (`1.4.1` as of Feb 2024) or unstable (`main`
branch), and Lua version/implementation, PUC Lua from `5.1` to `5.4` or
LuaJIT.

You can access them via attributes

```nix
pkgs."fennel-${LUA}" # stable version
# or
pkgs."fennel-unstable-${LUA}" # main branch head
```

where `${LUA}` is either one of `lua5_1`, `lua5_2`, `lua5_3`, `lua5_4`,
and `luajit`. 

### Faith

A testing library. Attributes:

```nix
pkgs.faith # stable version (0.1.2 as of Feb 2024)
# or
pkgs.faith-unstable # main branch head
```

In this flake, the package contains a runnable script of Faith,
`bin/faith`. The script begins with shebang line
`#!/usr/bin/env fennel`, thus enabling you to test your code against
different Fennel variants.

Don't forget to add the Faith script path to environment variable
`$FENNEL_PATH`, so that you can require Faith module in your test code.
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

or in console shell (below is a Bash example):

```bash
export FENNEL_PATH="$(dirname $(which faith))/?"
```

For more information, take a look at [Faith's repository][2].

### Fennel Format

A Fennel formatter. Attributes:

```nix
pkgs.fnlfmt # stable version (0.3.1 as of Feb 2024)
# or
pkgs.fnlfmt-unstable # main branch head
```

Nothing special has been done for Nix usage. Install it and format code
as usual. For more information, read the document in
[Fennel Format's repository][3].

### Fenneldoc

A Fennel API documentation generator. Attribute:

```nix
pkgs.fenneldoc # development version (1.0.1-dev as of Feb 2024)
```

Again, once installed, you can just use it. For more information, read
the document in [Fenneldoc's repository][4].

### fennel-ls

A language server for Fennel. Attributes:

```nix
pkgs.fennel-ls # stable version (0.1.1 as of Feb 2024)
# or
pkgs.fennel-ls-unstable # main branch head
sk
```

Note that, regardless of this flake, you can use the official nixpkgs'
package `pkgs.fennel-ls` or the Nix flake provided by fennel-ls itself:

```nix
inputs.fennel-ls.url = "sourcehut:~xerool/fennel-ls/main";
```

This flake provides its own `fennel-ls` package just for completeness.

## License

[BSD 3-clause](LICENSE)

<!-- vim:set tw=72 spell nowrap: -->

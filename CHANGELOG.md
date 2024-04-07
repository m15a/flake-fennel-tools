# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][1],
and this project adheres to [Semantic Versioning][2].

[1]: https://keepachangelog.com/en/1.1.0/
[2]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

## [0.5.0] (2024-04-07)

### Added

- fennel: `withLuaPackages` passthru attribute [#15]:
  it now supports an expression such as
  `pkgs.fennel-luajit.withLuaPackages (ps: with ps; [ cjson ])`.

[#15]: https://github.com/m15a/flake-fennel-tools/issues/15

## [0.4.0] (2024-04-03)

### Improved

- fennel-ls-unstable: append development version, e.g.,
  `0.1.2-dev-5fa5a0a`.

### Fixed

- flake.lock: remove unnecessary development dependencies
  introduced in 0.3.0.

## [0.3.0] (2024-03-30)

### Improved

- fennel: separate `out` and `man` pacakges.
  - No need to download pandoc package everytime, useful for CI.

## [0.2.0] (2024-02-27)

### Added packages

- fennel-ls: stable `0.1.1` and the unstable version

## [0.1.3] (2024-02-25)

### Bumped package versions

- fennel: `1.4.2`
- fennel-unstable: `1.5.0-dev`, again!

## [0.1.2] (2024-02-24)

### Downgraded package versions

- fennel-unstable: `1.5.0-dev` -> `1.4.2-dev`

## [0.1.1] (2024-02-22)

### Bumped package versions

- fennel: `1.4.1`
- fennel-unstable: `1.5.0-dev`

## [0.1.0] (2024-02-20)

- Initial release of development version.
- Included Fennel tools:
  - Fennel: versions `1.4.0` and `1.4.1-dev`
  - Faith: versions `0.1.2` and `0.1.3-dev`
  - Fnlfmt: versions `0.3.1` und `0.3.2-dev`
  - Fenneldoc: version `1.0.1-dev`

[Unreleased]: https://github.com/m15a/flake-fennel-tools/tree/HEAD
[0.5.0]: https://github.com/m15a/flake-fennel-tools/tree/v0.5.0
[0.4.0]: https://github.com/m15a/flake-fennel-tools/tree/v0.4.0
[0.3.0]: https://github.com/m15a/flake-fennel-tools/tree/v0.3.0
[0.2.0]: https://github.com/m15a/flake-fennel-tools/tree/v0.2.0
[0.1.3]: https://github.com/m15a/flake-fennel-tools/tree/v0.1.3
[0.1.2]: https://github.com/m15a/flake-fennel-tools/tree/v0.1.2
[0.1.1]: https://github.com/m15a/flake-fennel-tools/tree/v0.1.1
[0.1.0]: https://github.com/m15a/flake-fennel-tools/tree/v0.1.0

<!-- vim:set tw=72 spell nowrap: -->

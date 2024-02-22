# Contributing Guidelines

## Commit message style

### Format

Follow the style of [conventional commits][1]:

```
<type>[optional scope][optional bang]: <short description>

<optional body>

<optional footer>
```

where `[optional scope]` should be enclosed by parentheses, e.g., `(nix)`,
and `[optional bang]` should be `!` if any, indicating that the commit contains
breaking changes.

### Types

- **fix**: Fix a bug.
- **feat**: Introduce a new feature.
- **refactor**: Change codes but do neither fix any bug nor introduce new features.
- **bump**: Bump or downgrade package version.
- **style**: Just format codes. Small refactoring (e.g., changing a variable name)
  could be included, though.
- **test**: Add, fix, change, or refactor test codes.
- **docs**: Add, fix, change, or improve writing of documentation.
- **ci**: Add, fix, change, or refactor CI stuff (e.g, GitHub workflows).
- **tools**: Add, fix, change, or refactor development tools (e.g, formatters).
- **release**: Bump version of this repository itself. Any Git tag should be
  attached to these commits.
- **auto**: Commits done by GitHub workflows automatically.

### Scopes

- **readme**: `README.md`, as is.
- **nix**: Nix stuff. `flake.nix`, `flake.lock`, or those found in `./nix/`.
- **[package name]**: Specific package. `fennel`, `fnlfmt`, etc.

[1]: https://www.conventionalcommits.org/en/v1.0.0/

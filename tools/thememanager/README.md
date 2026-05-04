# thememanager

Palette tooling for the dotfiles theming system.

## Interface

- CLI launchers: `thememanager` and `color256`
- Palette Artifact: `${XDG_DATA_HOME:-~/.local/share}/theme/palette.json`
- Theme source: `src/color256/themes/*.txt`
- Adapter runner: `theme-apply-all`

This repo owns palette generation and color expansion. Dotfiles-owned adapters
such as `theme-apply-all` live in the dotfiles repo and call the installed CLI.

## Layout

- `pyproject.toml` - package metadata and console entry points
- `src/thememanager.py` - palette producer CLI
- `src/color256/` - terminal palette expansion CLI and built-in themes
- `tests/` - Python unit tests for palette artifact behavior
- `docs/` - color256 notes and writeup assets

## Tests

```bash
just test
just build
just ci
```

Package entry points can be smoke-tested without installation:

```bash
PYTHONPATH=src python3 -m thememanager list
PYTHONPATH=src python3 -m color256.color256 --help
```

## Install

```bash
uv tool install --reinstall .
```

Without `uv`, use `pipx`:

```bash
pipx install --force .
```

## Release

Create a release tag from a clean tree:

```bash
just release
```

The release recipe reads `pyproject.toml`, runs `just ci`, and creates the tag
`v<version>`. Push the commit and tag from git after review.

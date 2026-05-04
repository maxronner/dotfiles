# thememanager

Palette tooling for the dotfiles theming system.

## Interface

- CLI launchers: `thememanager` and `color256`
- Palette Artifact: `${XDG_DATA_HOME:-~/.local/share}/theme/palette.json`
- Theme source: `src/color256/themes/*.txt`
- Adapter runner: `theme-apply-all`

The source module owns palette generation and color expansion. Dotfiles-owned
adapters stay in `local/dot-local/lib/theme`, and installed command launchers
stay in `local/dot-local/bin`.

## Layout

- `src/thememanager` - palette producer CLI
- `src/color256/` - terminal palette expansion CLI and built-in themes
- `tests/` - Python unit tests for palette artifact behavior
- `docs/` - color256 notes and writeup assets

## Tests

```bash
python3 tools/thememanager/tests/test_thememanager.py
```

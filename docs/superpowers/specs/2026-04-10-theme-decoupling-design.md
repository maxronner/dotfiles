# Theme Decoupling: Make palette.json the Contract

**Date:** 2026-04-10
**Status:** Draft

## Problem

`thememanager` currently does two jobs: palette generation and palette application.
This makes it a hard bootstrap dependency — apps cannot render their themed configs
without running thememanager, which requires Python, matugen, and color256.

## Goal

Make `palette.json` the stable shared contract. Move theme application into each
consuming app. Reduce `thememanager` to an optional palette producer.

## Architecture

Three layers with clear ownership:

```
palette.json          ← shared contract (schema is the API)
lib/theme/render      ← shared primitive (template substitution)
per-app apply-theme   ← app-owned behavior (render + reload)
theme-apply-all       ← orchestrator (discovery + coordination)
thememanager          ← optional producer (palette generation only)
```

Dependency graph after refactor:

```
nvim           ──→ palette.json (direct read, no render step)
sway           ──→ palette.json + lib/theme/render
waybar         ──→ palette.json + lib/theme/render
swaylock       ──→ palette.json + lib/theme/render
mako           ──→ palette.json + lib/theme/render
ghostty        ──→ palette.json (direct key extraction via jq)
theme-apply-all──→ per-app apply-theme scripts
thememanager   ──→ palette.json (write only), theme-apply-all (optional)
```

## File Layout

### New files

```
local/dot-local/lib/theme/render                        # shared renderer
local/dot-local/bin/theme-apply-all                     # orchestrator
apps/sway/dot-config/sway/scripts/apply-theme           # app-owned
apps/sway/dot-config/sway/templates/theme.config.tmpl   # moved from thememanager
apps/waybar/dot-config/waybar/scripts/apply-theme
apps/waybar/dot-config/waybar/templates/style.css.tmpl
apps/swaylock/dot-config/swaylock/scripts/apply-theme
apps/swaylock/dot-config/swaylock/templates/config.tmpl
apps/mako/dot-config/mako/scripts/apply-theme
apps/mako/dot-config/mako/templates/theme.ini.tmpl
apps/ghostty/dot-config/ghostty/scripts/apply-theme
```

### Removed files

```
apps/thememanager/dot-config/thememanager/apps.json
apps/thememanager/dot-config/thememanager/templates/     # entire directory
apps/thememanager/dot-config/thememanager/reload-ghostty.sh
apps/thememanager/dot-config/thememanager/reload-pinentry-gtk.sh  # pinentry theming dropped
```

### Unchanged

```
apps/thememanager/dot-config/thememanager/palette.json   # stays as default seed
apps/nvim/                                               # already reads palette.json directly
```

---

## Contract 1: palette.json Schema

The palette is a flat JSON object. All values are strings. Keys match `[A-Za-z0-9_]+`.

### Required keys (used by at least one template)

```
bg, fg, accent
color0 through color15
color0_nh through color15_nh
bg_nh, fg_nh, accent_nh
base, surface, overlay, muted, subtle, text
primary, secondary, success, warning, critical, info
highlightlow, highlightmed, highlighthigh, indicator
terminal_palette
```

### Optional keys

```
theme_name, wallpaper
```

Producers must emit all required keys. Consumers may use any subset.

---

## Contract 2: lib/theme/render

### Location

Installed at `~/.local/lib/theme/render` via directory symlink:

```
~/.local/lib/theme → <repo>/local/dot-local/lib/theme
```

This is an **installation invariant**: the install system guarantees this symlink
exists after `stow-scripts.sh` runs.

### Interface

```
render <palette.json> <template> [output]
```

- If `output` is omitted or `-`, render to stdout.
- If `output` is a path, write atomically (temp file + `mv`).
- Temp file created with current `umask`. No explicit chmod.
  Apps needing stricter permissions must chmod after render.

### Placeholder syntax

- Valid: `{{key}}` and `{{ key }}` (whitespace inside braces is trimmed)
- Key grammar: `[A-Za-z0-9_]+`
- Repeated placeholders in a template are replaced at every occurrence.

### Failure behavior

| Condition | Behavior |
|-----------|----------|
| Palette file missing | Exit non-zero |
| Template file missing | Exit non-zero |
| Palette is invalid JSON | Exit non-zero |
| Referenced key missing from palette | Exit non-zero (fatal) |
| Unreferenced palette keys | Ignored (silent) |
| Malformed placeholder (e.g. `{{foo bar}}`, `{{% x }}`) | Left as-is (not a placeholder) |
| Output write fails | Exit non-zero |

### Implementation notes

- Uses `jq` for JSON parsing. `jq` is an existing system dependency.
- Template substitution must handle values containing `/`, `&`, `\`, and newlines
  safely. Plain `sed s///` is insufficient for the `terminal_palette` key which
  contains newlines. Implementation should use `awk` or a jq-native approach
  rather than per-key sed replacement.
- Unused palette keys produce no warnings.

### Exit codes

- 0: success
- 1: usage/input error (missing args, missing files, bad JSON)
- 2: render error (missing key, write failure)

---

## Contract 3: Per-app apply-theme Scripts

### Location convention

```
~/.config/<app>/scripts/apply-theme
```

Stowed from:

```
apps/<app>/dot-config/<app>/scripts/apply-theme
```

### Template location convention

```
~/.config/<app>/templates/<filename>.tmpl
```

Template naming is app-owned. Only the apply script references templates.

### Behavioral contract

```
apply-theme [--check]
```

**Normal mode:**

1. Check for palette at `$XDG_CONFIG_HOME/thememanager/palette.json`.
   If missing: exit 0 (silent skip).
2. Check for renderer at `$HOME/.local/lib/theme/render`.
   If missing but palette exists: exit non-zero (broken install).
3. Render template(s) to destination.
   If render fails: exit non-zero.
4. Reload app if running.
   If reload fails: log to stderr, exit 0 (non-fatal).

**Check mode (`--check`):**

1. Same as normal mode steps 1-3, but render to stdout (or /dev/null).
2. Skip reload entirely.
3. Exit 0 if render would succeed.

### Failure semantics summary

| Condition | Exit code |
|-----------|-----------|
| No palette | 0 (skip) |
| Palette exists, renderer missing | Non-zero |
| Render failure | Non-zero |
| Reload failure | 0 (logged to stderr) |

### Ghostty special case

Ghostty does not use a template. Its apply-theme script:

1. Reads `terminal_palette` key from palette.json via `jq -r .terminal_palette`
2. Writes to `~/.config/ghostty/themes/color256-theme`
3. Sends `USR2` to running ghostty processes

---

## Contract 4: theme-apply-all Orchestrator

### Location

`~/.local/bin/theme-apply-all` (on PATH, user-facing command).

### Interface

```
theme-apply-all [--check]
```

### App list

Fixed list, not discovery-based:

```bash
apps=(sway waybar swaylock mako ghostty)
```

Adding an app means editing this list.

### Behavior

1. Check palette exists. If missing: print message to stderr, exit 0.
2. For each app in the list:
   - If apply script is not present or not executable: mark as skipped, continue.
   - Run apply script (pass `--check` if orchestrator was called with `--check`).
   - If script fails: mark as failed, continue to next app.
3. Print summary to stderr: `applied: N  skipped: N  failed: N`
4. If any app failed: exit 1. Otherwise: exit 0.

### Bootstrap tolerance

The orchestrator never stops on first failure. It always processes all apps.
This keeps bootstrap resilient even if one app has a broken template.

---

## Contract 5: thememanager Changes

### Removed

- `_apply_theme()` method (template rendering + direct write)
- `_apply_template()` method
- `_apply_direct()` method
- `_reload_apps()` method
- `_run_command()` method
- `_load_app_configs()` method and `self.app_configs`
- `apps.json` loading and usage
- `APP_CONFIG_FILE` constant

### Retained

- All palette generation logic (color256, matugen, hue rotation)
- `_build_semantic_palette()`
- `_palette_from_color256_theme()` (writes `terminal_palette` key into palette)
- `_palette_from_matugen()`
- `PALETTE_FILE` writing
- CLI: `list`, `get`, `set`, `auto` subcommands

### New behavior after palette write

After writing `palette.json`, thememanager calls `theme-apply-all` best-effort:

```python
apply_cmd = shutil.which("theme-apply-all")
if apply_cmd:
    subprocess.run([apply_cmd], check=False)
```

If `theme-apply-all` is not found, thememanager does not fail. This keeps the
decoupling intact — thememanager's job is producing a palette, not applying it.

---

## Bootstrap Ordering

Current (`install/user/finalize.sh` line 26):

```bash
python3 "${REPO_ROOT}/local/thememanager/thememanager" set auto
```

New:

```bash
# palette.json is already present via stow (committed default).
# Render themed configs from the existing palette.
theme-apply-all
```

### Prerequisites (must be true before `theme-apply-all` runs)

1. `stow-apps.sh` has run → app configs including templates are in place
2. `stow-scripts.sh` has run → `~/.local/lib/theme/render` and
   `~/.local/bin/theme-apply-all` symlinks exist
3. `palette.json` exists at `~/.config/thememanager/palette.json`
   (provided by the committed default via stow)

This ordering is already satisfied by the current `finalize.sh` flow, since
`stow-scripts.sh` runs on line 8 before the theme step on line 26, and
`stow-apps.sh` runs earlier in the user phase.

### Optional: generate a fresh palette

If the user wants wallpaper-derived theming, they run `thememanager set auto`
separately. This is no longer part of the default bootstrap path.

---

## stow-scripts.sh Change

Add directory symlink support for `lib/` subdirectories.

Current behavior (lines 20-24) symlinks individual files from
`local/dot-local/lib/*`. Extend to also handle directories:

```bash
for lib_entry in "${REPO_ROOT}/local/dot-local/lib"/*; do
    if [[ -f "$lib_entry" ]]; then
        ln -sf "$lib_entry" "${HOME_DIR}/.local/lib/"
    elif [[ -d "$lib_entry" ]]; then
        ln -sfn "$lib_entry" "${HOME_DIR}/.local/lib/$(basename "$lib_entry")"
    fi
done
```

This creates `~/.local/lib/theme → <repo>/local/dot-local/lib/theme`.

---

## What This Does Not Change

- **Nvim** continues reading `palette.json` directly at runtime. No apply script.
- **Tmux** theme handling (if any) is unrelated and unchanged.
- **color256** and **matugen** remain thememanager internals.
- **Named theme files** (`.txt` in `local/thememanager/color256/themes/`) and
  `stow-themes.sh` are unchanged.
- **palette.json schema** is unchanged from what thememanager currently produces.

## Risks

1. **`terminal_palette` contains newlines.** The renderer must handle multi-line
   values. This is the main implementation hazard. Using `awk` with pre-loaded
   key-value pairs or a `jq`-native template approach avoids sed pitfalls.

2. **Template drift.** Now that templates live in app dirs, a palette schema
   change requires updating multiple apps. Mitigation: the required-keys list
   in this spec is the source of truth. A `theme-apply-all --check` validates
   all templates against the current palette.

3. **Stow ordering during first install.** If palette.json's parent directory
   doesn't exist yet when stow runs, stow creates it. This should work with
   `--no-folding` but is worth verifying.

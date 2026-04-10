# Theme Decoupling: Make palette.json the Contract

**Date:** 2026-04-10
**Status:** Approved

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
apps/thememanager/dot-config/thememanager/templates/              # entire directory
apps/thememanager/dot-config/thememanager/reload-ghostty.sh
apps/thememanager/dot-config/thememanager/reload-pinentry-gtk.sh  # pinentry theming dropped
```

### Changed files

```
apps/thememanager/dot-config/thememanager/palette.json   # renamed to palette.seed.json, moved (see below)
```

### Unchanged

```
apps/nvim/    # already reads palette.json directly
```

---

## Invariant: Repo State vs Runtime State

This refactor introduces an explicit boundary between repo-backed defaults and
mutable runtime artifacts.

**Repo-backed (read-only, stowed):**
- Templates (`apps/<app>/dot-config/<app>/templates/*.tmpl`)
- Apply scripts (`apps/<app>/dot-config/<app>/scripts/apply-theme`)
- Renderer (`local/dot-local/lib/theme/render`)
- Palette seed (`apps/thememanager/dot-config/thememanager/palette.seed.json`)

**Runtime artifacts (mutable, not stowed, not tracked):**
- Live palette (`$XDG_DATA_HOME/theme/palette.json`)
- Rendered app configs (e.g. `~/.config/sway/theme.config`,
  `~/.config/waybar/style.css`, `~/.config/swaylock/config`,
  `~/.config/mako/theme.ini`, `~/.config/ghostty/themes/color256-theme`)

Generated outputs must never be stowed symlinks into the repo. They are local
mutable files owned by the rendering system.

---

## Contract 1: palette.json Schema

### Location

Live palette is stored as shared application data, not app-specific config:

```
${XDG_DATA_HOME:-$HOME/.local/share}/theme/palette.json
```

This path is the **canonical contract location**. All consumers and producers
use this path. The directory `theme/` is neutral — it is not owned by
thememanager or any single app.

### Path resolution

All scripts use:

```bash
THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_FILE="${THEME_DATA_DIR}/palette.json"
```

The Python producer uses the equivalent:

```python
XDG_DATA_HOME = os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local" / "share"))
PALETTE_FILE = Path(XDG_DATA_HOME) / "theme" / "palette.json"
```

### Format

The palette is a flat JSON object. All values are strings.
Keys match `[A-Za-z0-9_]+`.

### Required key: schema_version

```json
{
  "schema_version": "1",
  ...
}
```

- Value is a string (consistent with "all values are strings" rule).
- Consumers should check this key and fail fast on unrecognized versions.
- Incrementing `schema_version` signals a breaking change to the key set.

### Required keys (used by at least one consumer)

```
schema_version
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

### Schema governance

- Only `thememanager` (or a replacement producer) may expand the required key set.
- Apps may consume optional keys but cannot implicitly make them required for
  all producers.
- If a new key becomes broadly required, bump `schema_version`.

Producers must emit all required keys. Consumers may use any subset.

---

## Palette Seed and Bootstrap

The repo contains a committed default palette:

```
apps/thememanager/dot-config/thememanager/palette.seed.json
```

This file is stowed to `~/.config/thememanager/palette.seed.json` — a read-only
reference, not the live palette.

During bootstrap (`finalize.sh`), the seed is copied into the live location
only if no live palette exists:

```bash
THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_FILE="${THEME_DATA_DIR}/palette.json"
SEED="${XDG_CONFIG_HOME:-$HOME/.config}/thememanager/palette.seed.json"

mkdir -p "$THEME_DATA_DIR"
if [[ ! -f "$PALETTE_FILE" ]] && [[ -f "$SEED" ]]; then
    cp "$SEED" "$PALETTE_FILE"
fi
```

After this point, the live palette is owned by `thememanager` (or any other
producer). The seed is never read again unless the live palette is deleted.

This ensures:
- Runtime state never dirties the repo working tree.
- Theme changes are not repository mutations.
- Bootstrap works without thememanager, matugen, or Python.
- Rollback is possible by deleting the live palette (falls back to seed on
  next bootstrap).

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
- Temp file must be created in the **same directory** as the output file
  to guarantee `mv` is atomic (same filesystem).
- Temp file created with current `umask`. No explicit chmod.
  Apps needing stricter permissions must chmod after render.

### Placeholder syntax

- Valid: `{{key}}` and `{{ key }}` (whitespace inside braces is trimmed)
- Key grammar: `[A-Za-z0-9_]+`
- Repeated placeholders in a template are replaced at every occurrence.

### Scope — what the renderer does NOT do

- No conditionals
- No loops
- No default values
- No nested lookups
- No include/import support
- No environment variable expansion

Only placeholder substitution. This keeps the primitive trivially replaceable.

### Encoding

- Input palette and templates are UTF-8 text.
- Output is emitted as UTF-8 bytes, unchanged except for substitution.

### Failure behavior

| Condition | Behavior |
|-----------|----------|
| Palette file missing | Exit 1 |
| Template file missing | Exit 1 |
| Palette is invalid JSON | Exit 1 |
| Referenced key missing from palette | Exit 2 (fatal) |
| Unreferenced palette keys | Ignored (silent) |
| Malformed placeholder (e.g. `{{foo bar}}`, `{{% x }}`) | Left as-is (not a placeholder) |
| Output write fails | Exit 2 |

### Strict mode

```
render --strict <palette.json> <template> [output]
```

In strict mode, after substitution the renderer scans the output for any
remaining tokens matching `\{\{[^}]*\}\}`. If any are found, it exits 2.

This catches template typos like `{{ foo-bar }}` (hyphen not in key grammar)
that normal mode would leave untouched.

Per-app `--check` invokes the renderer with `--strict`. Normal apply does not.

### Exit codes

- 0: success
- 1: usage/input error (missing args, missing files, bad JSON)
- 2: render error (missing key, write failure, unresolved placeholder in strict mode)

### Implementation notes

- Uses `jq` for JSON parsing. `jq` is an existing system dependency.
- Template substitution must handle values containing `/`, `&`, `\`, and
  newlines safely. Plain `sed s///` is insufficient for the `terminal_palette`
  key which contains newlines. Implementation should use `awk` or a jq-native
  approach rather than per-key sed replacement.
- Unused palette keys produce no warnings.

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

1. Resolve palette path:
   `${XDG_DATA_HOME:-$HOME/.local/share}/theme/palette.json`.
   If missing: exit 0 (silent skip).
2. Check for renderer at `$HOME/.local/lib/theme/render`.
   If missing but palette exists: exit non-zero (broken install).
3. Render template(s) to destination.
   If render fails: exit non-zero.
4. Reload app if running.
   - App not running: silent no-op (no stderr output).
   - App running, reload command failed: log to stderr, exit 0 (non-fatal).

**Check mode (`--check`):**

1. Same as normal mode steps 1-3, but render with `--strict` to /dev/null.
2. Skip reload entirely.
3. Exit 0 if render would succeed. Exit non-zero if render fails or
   unresolved placeholders remain (strict mode).

### stdout/stderr discipline

- stdout is reserved for rendered output (used in `--check` piping).
- stderr is reserved for diagnostics and reload messages.
- Normal mode should not emit rendered content to stdout.

### Output directory creation

Apply scripts must `mkdir -p` the target's parent directory before writing.
This ensures first-install robustness when generated config directories do
not yet exist (e.g. `~/.config/ghostty/themes/`).

### Failure semantics summary

| Condition | Exit code |
|-----------|-----------|
| No palette | 0 (skip) |
| Palette exists, renderer missing | Non-zero |
| Render failure | Non-zero |
| App not running | 0 (silent) |
| Reload failure (app running) | 0 (logged to stderr) |

### Ghostty special case

Ghostty is a first-party consumer of `palette.json` that uses direct key
extraction instead of template rendering. This is not an exception to the
contract, only a different consumption mechanism.

Its apply-theme script:

1. Reads `terminal_palette` key from palette.json via `jq -r .terminal_palette`
2. Writes atomically to `~/.config/ghostty/themes/color256-theme`
   (temp file in same directory + `mv`)
3. Sends `USR2` to running ghostty processes (silent no-op if not running)

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

### Concurrency

A single lockfile guards both palette writes and theme application:

```bash
THEME_LOCK="${XDG_RUNTIME_DIR:-/tmp}/theme.${UID}.lock"
```

`theme-apply-all` acquires this lock before processing apps:

```bash
exec 9>"$THEME_LOCK"
flock -n 9 || { echo "theme-apply-all: already running" >&2; exit 0; }
```

`thememanager` acquires the **same lock** before writing `palette.json` and
holds it through the `theme-apply-all` invocation:

```python
lock_path = os.environ.get("XDG_RUNTIME_DIR", "/tmp") + f"/theme.{os.getuid()}.lock"
lock_fd = os.open(lock_path, os.O_CREAT | os.O_WRONLY)
fcntl.flock(lock_fd, fcntl.LOCK_EX)
# ... write palette.json ...
# ... call theme-apply-all (which will skip flock since fd is inherited) ...
fcntl.flock(lock_fd, fcntl.LOCK_UN)
```

This prevents the race where `thememanager` writes a new palette while an
in-flight `theme-apply-all` has already started rendering with the old one.

The lockfile is per-user (`${UID}`) to avoid conflicts in multi-user
environments.

This matters because the orchestrator can be invoked from:
- Bootstrap (`finalize.sh`)
- `thememanager` after palette generation
- Manual user invocation

Without locking, concurrent runs could interleave palette writes, template
renders, and reload commands.

### Bootstrap tolerance

The orchestrator never stops on first failure. It always processes all apps.
This keeps bootstrap resilient even if one app has a broken template.

### Check mode

When `--check` is passed, `theme-apply-all` runs each apply script with
`--check`. Each apply script invokes the renderer in `--strict` mode, which
catches both missing keys and unresolved placeholder-like tokens.

Unresolved placeholders are **fatal** in check mode — they mark the app as
failed. This makes `theme-apply-all --check` usable as a validator for CI
and schema migrations.

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
- `_build_semantic_palette()` — updated to include `schema_version: "1"`
- `_palette_from_color256_theme()` (writes `terminal_palette` key into palette)
- `_palette_from_matugen()`
- `PALETTE_FILE` writing — updated to new path
  (`$XDG_DATA_HOME/theme/palette.json`)
- CLI: `list`, `get`, `set`, `auto` subcommands

### Palette write and apply

`thememanager` acquires the shared theme lock, writes `palette.json` atomically
(temp file in same directory + `os.rename`), then calls `theme-apply-all`
best-effort, all under the same lock:

```python
import fcntl

lock_path = os.environ.get("XDG_RUNTIME_DIR", "/tmp") + f"/theme.{os.getuid()}.lock"
lock_fd = os.open(lock_path, os.O_CREAT | os.O_WRONLY)
fcntl.flock(lock_fd, fcntl.LOCK_EX)
try:
    # atomic write palette.json (temp + os.rename)
    ...
    # best-effort apply
    apply_cmd = shutil.which("theme-apply-all")
    if apply_cmd:
        subprocess.run([apply_cmd], check=False)
finally:
    fcntl.flock(lock_fd, fcntl.LOCK_UN)
    os.close(lock_fd)
```

The atomic write is critical because direct readers like nvim may observe
the file at any time. The lock ensures palette write and theme application
are a single atomic operation from the perspective of concurrent invocations.

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
# Seed palette if no live palette exists
THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_SEED="${XDG_CONFIG_HOME:-$HOME/.config}/thememanager/palette.seed.json"
mkdir -p "$THEME_DATA_DIR"
if [[ ! -f "$THEME_DATA_DIR/palette.json" ]] && [[ -f "$PALETTE_SEED" ]]; then
    cp "$PALETTE_SEED" "$THEME_DATA_DIR/palette.json"
fi

# Render themed configs from the existing palette
theme-apply-all
```

### Prerequisites (must be true before `theme-apply-all` runs)

1. `stow-apps.sh` has run → app configs including templates are in place,
   and `palette.seed.json` is stowed
2. `stow-scripts.sh` has run → `~/.local/lib/theme/render` and
   `~/.local/bin/theme-apply-all` symlinks exist
3. Palette seed has been copied to live location (step above)

This ordering is satisfied by the current `finalize.sh` flow, since
`stow-scripts.sh` runs on line 8 before the theme step on line 26, and
`stow-apps.sh` runs earlier in the user phase.

### First-install note

Some app configs (sway theme.config, waybar style.css, swaylock config, mako
theme.ini, ghostty color256-theme) are generated artifacts that do not exist
until `theme-apply-all` runs once. App startup before finalize may show
unthemed defaults. This is acceptable since finalize is part of the install
invariant.

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

## Nvim Consumer Update

Nvim currently reads `palette.json` from `$XDG_CONFIG_HOME/thememanager/palette.json`.
This path changes to `$XDG_DATA_HOME/theme/palette.json`.

Files to update:
- `apps/nvim/dot-config/nvim/plugin/colors.lua` (line 10)
- `apps/nvim/dot-config/nvim/lua/custom/theme.lua` (line 166)

Both already guard on file existence, so the path change is safe.

---

## What This Does Not Change

- **Nvim** continues reading `palette.json` directly at runtime. No apply script.
- **Tmux** theme handling (if any) is unrelated and unchanged.
- **color256** and **matugen** remain thememanager internals.
- **Named theme files** (`.txt` in `local/thememanager/color256/themes/`) and
  `stow-themes.sh` are unchanged.

## Risks

1. **`terminal_palette` contains newlines.** The renderer must handle multi-line
   values. This is the main implementation hazard. Using `awk` with pre-loaded
   key-value pairs or a `jq`-native template approach avoids sed pitfalls.

2. **Template drift.** Now that templates live in app dirs, a palette schema
   change requires updating multiple apps. Mitigation: the required-keys list
   in this spec is the source of truth. `theme-apply-all --check` validates
   all templates against the current palette.

3. **Stow ordering during first install.** If palette.seed.json's parent
   directory doesn't exist yet when stow runs, stow creates it. This should
   work with `--no-folding` but is worth verifying.

4. **Concurrent invocation.** `thememanager set auto` and manual
   `theme-apply-all` could race. Mitigated by flock in the orchestrator.

---

## ADR: Make palette.json the Theme Contract

### Status

Approved

### Context

The current thememanager is responsible for both producing palettes and applying
them to multiple apps. This makes it a bootstrap dependency and couples palette
generation logic to per-app rendering and reload behavior. As a result, themed
configs cannot be rendered unless thememanager and its Python dependencies are
available.

### Decision

Adopt `palette.json` as the stable shared contract for theming.

- `thememanager` becomes an optional palette producer only
- `lib/theme/render` provides a minimal shared substitution primitive
- Each app owns its own `apply-theme` behavior and reload logic
- `theme-apply-all` coordinates application across a fixed app list
- Bootstrap uses an existing/seeded palette and runs `theme-apply-all`
- Palette generation from wallpaper becomes an optional later action
- Live palette is stored in `$XDG_DATA_HOME/theme/` as shared data,
  not in any app's config directory

### Consequences

**Easier:**
- Bootstrap no longer depends on Python palette generation
- App-specific theme behavior is localized to each app
- Failures are isolated per consumer
- Adding a new consumer does not require central thememanager knowledge
- Runtime state does not dirty the repo working tree

**Harder:**
- Schema evolution requires coordination across multiple app-owned templates
- Shared renderer correctness becomes more important
- Generated runtime state must be kept separate from repo-backed templates
- Operational tooling must handle partial success across apps

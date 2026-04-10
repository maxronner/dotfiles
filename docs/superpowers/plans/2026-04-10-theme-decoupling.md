# Theme Decoupling Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Decouple theme application from thememanager so that palette.json is the stable contract and each app owns its own theme rendering.

**Architecture:** A shared renderer (`lib/theme/render`) does `{{key}}` substitution. Per-app `apply-theme` scripts call it with app-local templates. An orchestrator (`theme-apply-all`) coordinates all apps. `thememanager` becomes an optional palette producer that writes to `$XDG_DATA_HOME/theme/palette.json`.

**Tech Stack:** Bash, jq, awk (renderer); Python (thememanager changes); Lua (nvim path update)

**Spec:** `docs/superpowers/specs/2026-04-10-theme-decoupling-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `local/dot-local/lib/theme/render` | Create | Shared template renderer |
| `local/dot-local/bin/theme-apply-all` | Create | Orchestrator |
| `apps/sway/dot-config/sway/scripts/apply-theme` | Create | Sway theme apply |
| `apps/sway/dot-config/sway/templates/theme.config.tmpl` | Move | Sway template (from thememanager) |
| `apps/waybar/dot-config/waybar/scripts/apply-theme` | Create | Waybar theme apply |
| `apps/waybar/dot-config/waybar/templates/style.css.tmpl` | Move | Waybar template (from thememanager) |
| `apps/swaylock/dot-config/swaylock/scripts/apply-theme` | Create | Swaylock theme apply |
| `apps/swaylock/dot-config/swaylock/templates/config.tmpl` | Move | Swaylock template (from thememanager) |
| `apps/mako/dot-config/mako/scripts/apply-theme` | Create | Mako theme apply |
| `apps/mako/dot-config/mako/templates/theme.ini.tmpl` | Move | Mako template (from thememanager) |
| `apps/ghostty/dot-config/ghostty/scripts/apply-theme` | Create | Ghostty theme apply |
| `apps/thememanager/dot-config/thememanager/palette.seed.json` | Rename | Palette seed (was palette.json) |
| `local/thememanager/thememanager` | Modify | Strip apply logic, add lock + new palette path |
| `install/lib/stow-scripts.sh` | Modify | Add lib directory symlink support |
| `install/user/finalize.sh` | Modify | Replace thememanager call with seed+apply |
| `apps/nvim/dot-config/nvim/plugin/colors.lua` | Modify | Update palette path |
| `apps/nvim/dot-config/nvim/lua/custom/theme.lua` | Modify | Update palette path |
| `apps/thememanager/dot-config/thememanager/apps.json` | Delete | No longer needed |
| `apps/thememanager/dot-config/thememanager/templates/` | Delete | Moved to apps |
| `apps/thememanager/dot-config/thememanager/reload-ghostty.sh` | Delete | Absorbed into ghostty apply-theme |
| `apps/thememanager/dot-config/thememanager/reload-pinentry-gtk.sh` | Delete | Dropped |

---

### Task 1: Create the shared renderer

The renderer is the foundational primitive. Everything else depends on it.

**Files:**
- Create: `local/dot-local/lib/theme/render`

- [ ] **Step 1: Create `local/dot-local/lib/theme/render`**

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: render [--strict] <palette.json> <template> [output]" >&2
  exit 1
}

strict=0
if [[ "${1:-}" == "--strict" ]]; then
  strict=1
  shift
fi

[[ $# -ge 2 ]] || usage

palette_file="$1"
template_file="$2"
output="${3:-}"

[[ -f "$palette_file" ]] || { echo "render: palette not found: $palette_file" >&2; exit 1; }
[[ -f "$template_file" ]] || { echo "render: template not found: $template_file" >&2; exit 1; }

# Validate JSON and extract all keys/values into an awk-friendly format.
# jq outputs: KEY\x00VALUE\x00 for each entry (null-delimited to handle newlines in values).
palette_dump=$(jq -j 'to_entries[] | .key + "\u0000" + .value + "\u0000"' "$palette_file" 2>/dev/null) \
  || { echo "render: invalid JSON in $palette_file" >&2; exit 1; }

# Perform substitution using awk.
# 1. Load palette key/value pairs from null-delimited string.
# 2. Read entire template, replace all {{key}} and {{ key }} occurrences.
# 3. Check for missing keys (referenced in template but not in palette).
rendered=$(awk -v palette="$palette_dump" -v strict="$strict" '
BEGIN {
  # Parse null-delimited palette into associative array
  n = split(palette, parts, "\0")
  for (i = 1; i < n; i += 2) {
    key = parts[i]
    val = parts[i+1]
    pal[key] = val
    has[key] = 1
  }
}
{
  lines[NR] = $0
}
END {
  # Join all lines
  content = ""
  for (i = 1; i <= NR; i++) {
    if (i > 1) content = content "\n"
    content = content lines[i]
  }

  # Replace {{ key }} and {{key}} patterns
  missing = 0
  result = ""
  rest = content
  while (match(rest, /\{\{[ \t]*[A-Za-z0-9_]+[ \t]*\}\}/)) {
    result = result substr(rest, 1, RSTART - 1)
    token = substr(rest, RSTART, RLENGTH)
    rest = substr(rest, RSTART + RLENGTH)

    # Extract key name (trim braces and whitespace)
    key = token
    gsub(/^\{\{[ \t]*/, "", key)
    gsub(/[ \t]*\}\}$/, "", key)

    if (has[key]) {
      result = result pal[key]
    } else {
      print "render: missing palette key: " key > "/dev/stderr"
      missing = 1
    }
  }
  result = result rest

  if (missing) exit 2

  # Strict mode: check for any remaining {{ ... }} tokens
  if (strict && match(result, /\{\{[^}]*\}\}/)) {
    # Find and report all remaining tokens
    check = result
    while (match(check, /\{\{[^}]*\}\}/)) {
      token = substr(check, RSTART, RLENGTH)
      print "render: unresolved placeholder: " token > "/dev/stderr"
      check = substr(check, RSTART + RLENGTH)
    }
    exit 2
  }

  printf "%s", result
}
' "$template_file") || exit $?

# Output
if [[ -z "$output" || "$output" == "-" ]]; then
  printf '%s' "$rendered"
else
  # Atomic write: temp file in same directory, then mv
  output_dir=$(dirname "$output")
  mkdir -p "$output_dir"
  tmp=$(mktemp "${output_dir}/.render.XXXXXX")
  trap 'rm -f "$tmp"' EXIT
  printf '%s' "$rendered" > "$tmp" || { echo "render: write failed" >&2; exit 2; }
  mv "$tmp" "$output" || { echo "render: mv failed" >&2; exit 2; }
  trap - EXIT
fi
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x local/dot-local/lib/theme/render`

- [ ] **Step 3: Test the renderer manually against the existing palette**

Create a tiny test template and run the renderer to verify basic substitution:

Run:
```bash
echo '{{bg}} and {{ fg }}' > /tmp/test-theme.tmpl
./local/dot-local/lib/theme/render apps/thememanager/dot-config/thememanager/palette.json /tmp/test-theme.tmpl
```

Expected output: `#131318 and #e5e1e9`

- [ ] **Step 4: Test missing key detection**

Run:
```bash
echo '{{nonexistent_key}}' > /tmp/test-missing.tmpl
./local/dot-local/lib/theme/render apps/thememanager/dot-config/thememanager/palette.json /tmp/test-missing.tmpl; echo "exit: $?"
```

Expected: stderr message about missing key, exit code 2.

- [ ] **Step 5: Test strict mode**

Run:
```bash
echo '{{ foo-bar }}' > /tmp/test-strict.tmpl
./local/dot-local/lib/theme/render apps/thememanager/dot-config/thememanager/palette.json /tmp/test-strict.tmpl
echo "normal exit: $?"
./local/dot-local/lib/theme/render --strict apps/thememanager/dot-config/thememanager/palette.json /tmp/test-strict.tmpl
echo "strict exit: $?"
```

Expected: normal mode exits 0 (leaves `{{ foo-bar }}` as-is), strict mode exits 2.

- [ ] **Step 6: Test multi-line value substitution**

This is the critical test — `terminal_palette` contains newlines:

Run:
```bash
echo 'before
{{terminal_palette}}
after' > /tmp/test-multiline.tmpl
./local/dot-local/lib/theme/render apps/thememanager/dot-config/thememanager/palette.json /tmp/test-multiline.tmpl | head -5
echo "exit: $?"
```

Expected: first line is `before`, second line is `background = #131318`, exit code 0.

- [ ] **Step 7: Test atomic file output**

Run:
```bash
./local/dot-local/lib/theme/render apps/thememanager/dot-config/thememanager/palette.json /tmp/test-theme.tmpl /tmp/test-output.txt
cat /tmp/test-output.txt
```

Expected: file contains `#131318 and #e5e1e9`.

- [ ] **Step 8: Clean up test files and commit**

Run:
```bash
rm -f /tmp/test-theme.tmpl /tmp/test-missing.tmpl /tmp/test-strict.tmpl /tmp/test-multiline.tmpl /tmp/test-output.txt
git add local/dot-local/lib/theme/render
git commit -m "feat(theme): add shared template renderer

Bash+jq+awk renderer that does {{key}} substitution against palette.json.
Supports --strict mode, atomic file writes, and multi-line values."
```

---

### Task 2: Rename palette.json to palette.seed.json and add schema_version

**Files:**
- Rename: `apps/thememanager/dot-config/thememanager/palette.json` → `palette.seed.json`
- Modify: `apps/thememanager/dot-config/thememanager/palette.seed.json` (add schema_version)

- [ ] **Step 1: Rename the file**

Run:
```bash
git mv apps/thememanager/dot-config/thememanager/palette.json \
      apps/thememanager/dot-config/thememanager/palette.seed.json
```

- [ ] **Step 2: Add `schema_version` key to the seed file**

Add `"schema_version": "1"` as the first key in the JSON object (after the opening brace). The seed file already contains all required keys. Just add:

In `apps/thememanager/dot-config/thememanager/palette.seed.json`, after `{`:
```json
  "schema_version": "1",
```

- [ ] **Step 3: Verify the seed is valid JSON**

Run: `jq . apps/thememanager/dot-config/thememanager/palette.seed.json > /dev/null && echo "valid"`

Expected: `valid`

- [ ] **Step 4: Commit**

Run:
```bash
git add apps/thememanager/dot-config/thememanager/palette.seed.json
git commit -m "refactor(theme): rename palette.json to palette.seed.json, add schema_version

The seed is a committed default that gets copied to the live location
at bootstrap. It is no longer a mutable runtime file."
```

---

### Task 3: Move templates from thememanager to owning apps

**Files:**
- Move: `apps/thememanager/dot-config/thememanager/templates/sway/theme.config.tmpl` → `apps/sway/dot-config/sway/templates/theme.config.tmpl`
- Move: `apps/thememanager/dot-config/thememanager/templates/waybar/style.css.tmpl` → `apps/waybar/dot-config/waybar/templates/style.css.tmpl`
- Move: `apps/thememanager/dot-config/thememanager/templates/swaylock/config.tmpl` → `apps/swaylock/dot-config/swaylock/templates/config.tmpl`
- Move: `apps/thememanager/dot-config/thememanager/templates/mako/theme.ini.tmpl` → `apps/mako/dot-config/mako/templates/theme.ini.tmpl`

- [ ] **Step 1: Create destination directories**

Run:
```bash
mkdir -p apps/sway/dot-config/sway/templates
mkdir -p apps/waybar/dot-config/waybar/templates
mkdir -p apps/swaylock/dot-config/swaylock/templates
mkdir -p apps/mako/dot-config/mako/templates
```

- [ ] **Step 2: Move all templates**

Run:
```bash
git mv apps/thememanager/dot-config/thememanager/templates/sway/theme.config.tmpl \
      apps/sway/dot-config/sway/templates/theme.config.tmpl
git mv apps/thememanager/dot-config/thememanager/templates/waybar/style.css.tmpl \
      apps/waybar/dot-config/waybar/templates/style.css.tmpl
git mv apps/thememanager/dot-config/thememanager/templates/swaylock/config.tmpl \
      apps/swaylock/dot-config/swaylock/templates/config.tmpl
git mv apps/thememanager/dot-config/thememanager/templates/mako/theme.ini.tmpl \
      apps/mako/dot-config/mako/templates/theme.ini.tmpl
```

- [ ] **Step 3: Remove the now-empty templates directory**

Run:
```bash
rm -rf apps/thememanager/dot-config/thememanager/templates
```

- [ ] **Step 4: Commit**

Run:
```bash
git add -A apps/thememanager/dot-config/thememanager/templates
git commit -m "refactor(theme): move templates to owning apps

Each app now owns its template. Thememanager no longer stores
per-app rendering knowledge."
```

---

### Task 4: Create per-app apply-theme scripts (sway, waybar, swaylock, mako)

All four template-based apps follow the same pattern. Each script calls the shared renderer.

**Files:**
- Create: `apps/sway/dot-config/sway/scripts/apply-theme`
- Create: `apps/waybar/dot-config/waybar/scripts/apply-theme`
- Create: `apps/swaylock/dot-config/swaylock/scripts/apply-theme`
- Create: `apps/mako/dot-config/mako/scripts/apply-theme`

- [ ] **Step 1: Create `apps/sway/dot-config/sway/scripts/apply-theme`**

```bash
#!/usr/bin/env bash
set -euo pipefail

THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_FILE="${THEME_DATA_DIR}/palette.json"
RENDERER="$HOME/.local/lib/theme/render"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../templates/theme.config.tmpl"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/sway/theme.config"

[[ -f "$PALETTE_FILE" ]] || exit 0
[[ -x "$RENDERER" ]] || { echo "apply-theme[sway]: renderer missing: $RENDERER" >&2; exit 1; }

if [[ "${1:-}" == "--check" ]]; then
  "$RENDERER" --strict "$PALETTE_FILE" "$TEMPLATE" > /dev/null
  exit $?
fi

"$RENDERER" "$PALETTE_FILE" "$TEMPLATE" "$TARGET"

if pgrep -x sway > /dev/null 2>&1; then
  swaymsg reload 2>/dev/null || echo "apply-theme[sway]: reload failed" >&2
fi
```

- [ ] **Step 2: Create `apps/waybar/dot-config/waybar/scripts/apply-theme`**

```bash
#!/usr/bin/env bash
set -euo pipefail

THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_FILE="${THEME_DATA_DIR}/palette.json"
RENDERER="$HOME/.local/lib/theme/render"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../templates/style.css.tmpl"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/style.css"

[[ -f "$PALETTE_FILE" ]] || exit 0
[[ -x "$RENDERER" ]] || { echo "apply-theme[waybar]: renderer missing: $RENDERER" >&2; exit 1; }

if [[ "${1:-}" == "--check" ]]; then
  "$RENDERER" --strict "$PALETTE_FILE" "$TEMPLATE" > /dev/null
  exit $?
fi

"$RENDERER" "$PALETTE_FILE" "$TEMPLATE" "$TARGET"

# waybar has no simple reload command — it picks up CSS changes on restart
# or via sway reload (which restarts waybar). No explicit reload needed.
```

- [ ] **Step 3: Create `apps/swaylock/dot-config/swaylock/scripts/apply-theme`**

Note: swaylock has no `dot-config/swaylock/` directory yet in the stow tree, but templates were moved there in Task 3, which created the directory.

```bash
#!/usr/bin/env bash
set -euo pipefail

THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_FILE="${THEME_DATA_DIR}/palette.json"
RENDERER="$HOME/.local/lib/theme/render"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../templates/config.tmpl"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/swaylock/config"

[[ -f "$PALETTE_FILE" ]] || exit 0
[[ -x "$RENDERER" ]] || { echo "apply-theme[swaylock]: renderer missing: $RENDERER" >&2; exit 1; }

if [[ "${1:-}" == "--check" ]]; then
  "$RENDERER" --strict "$PALETTE_FILE" "$TEMPLATE" > /dev/null
  exit $?
fi

"$RENDERER" "$PALETTE_FILE" "$TEMPLATE" "$TARGET"

# swaylock reads config on each invocation. No reload needed.
```

- [ ] **Step 4: Create `apps/mako/dot-config/mako/scripts/apply-theme`**

```bash
#!/usr/bin/env bash
set -euo pipefail

THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_FILE="${THEME_DATA_DIR}/palette.json"
RENDERER="$HOME/.local/lib/theme/render"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../templates/theme.ini.tmpl"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/mako/theme.ini"

[[ -f "$PALETTE_FILE" ]] || exit 0
[[ -x "$RENDERER" ]] || { echo "apply-theme[mako]: renderer missing: $RENDERER" >&2; exit 1; }

if [[ "${1:-}" == "--check" ]]; then
  "$RENDERER" --strict "$PALETTE_FILE" "$TEMPLATE" > /dev/null
  exit $?
fi

"$RENDERER" "$PALETTE_FILE" "$TEMPLATE" "$TARGET"

if pgrep -x mako > /dev/null 2>&1; then
  makoctl reload 2>/dev/null || echo "apply-theme[mako]: reload failed" >&2
fi
```

- [ ] **Step 5: Make all scripts executable**

Run:
```bash
chmod +x apps/sway/dot-config/sway/scripts/apply-theme
chmod +x apps/waybar/dot-config/waybar/scripts/apply-theme
chmod +x apps/swaylock/dot-config/swaylock/scripts/apply-theme
chmod +x apps/mako/dot-config/mako/scripts/apply-theme
```

- [ ] **Step 6: Commit**

Run:
```bash
git add apps/sway/dot-config/sway/scripts/apply-theme \
        apps/waybar/dot-config/waybar/scripts/apply-theme \
        apps/swaylock/dot-config/swaylock/scripts/apply-theme \
        apps/mako/dot-config/mako/scripts/apply-theme
git commit -m "feat(theme): add per-app apply-theme scripts for sway, waybar, swaylock, mako

Each script owns its template path, output destination, and reload
behavior. Missing palette is a silent skip. Missing renderer is fatal."
```

---

### Task 5: Create ghostty apply-theme script

Ghostty uses direct key extraction instead of template rendering.

**Files:**
- Create: `apps/ghostty/dot-config/ghostty/scripts/apply-theme`

- [ ] **Step 1: Create `apps/ghostty/dot-config/ghostty/scripts/apply-theme`**

```bash
#!/usr/bin/env bash
set -euo pipefail

THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_FILE="${THEME_DATA_DIR}/palette.json"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes/color256-theme"

[[ -f "$PALETTE_FILE" ]] || exit 0

if [[ "${1:-}" == "--check" ]]; then
  jq -e -r '.terminal_palette' "$PALETTE_FILE" > /dev/null 2>&1
  exit $?
fi

content=$(jq -e -r '.terminal_palette' "$PALETTE_FILE") \
  || { echo "apply-theme[ghostty]: terminal_palette key missing" >&2; exit 1; }

# Atomic write
target_dir=$(dirname "$TARGET")
mkdir -p "$target_dir"
tmp=$(mktemp "${target_dir}/.apply-theme.XXXXXX")
trap 'rm -f "$tmp"' EXIT
printf '%s\n' "$content" > "$tmp"
mv "$tmp" "$TARGET"
trap - EXIT

# Reload running instances
mapfile -t pids < <(pgrep -x ghostty 2>/dev/null || true)
if (( ${#pids[@]} )); then
  kill -USR2 "${pids[@]}" 2>/dev/null || echo "apply-theme[ghostty]: reload failed" >&2
fi
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x apps/ghostty/dot-config/ghostty/scripts/apply-theme`

- [ ] **Step 3: Commit**

Run:
```bash
git add apps/ghostty/dot-config/ghostty/scripts/apply-theme
git commit -m "feat(theme): add ghostty apply-theme script

Uses direct jq extraction of terminal_palette key instead of
template rendering. Atomic write and USR2 reload."
```

---

### Task 6: Create the theme-apply-all orchestrator

**Files:**
- Create: `local/dot-local/bin/theme-apply-all`

- [ ] **Step 1: Create `local/dot-local/bin/theme-apply-all`**

```bash
#!/usr/bin/env bash
set -euo pipefail

THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_FILE="${THEME_DATA_DIR}/palette.json"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
THEME_LOCK="${XDG_RUNTIME_DIR:-/tmp}/theme.${UID}.lock"

check=0
if [[ "${1:-}" == "--check" ]]; then
  check=1
fi

if [[ ! -f "$PALETTE_FILE" ]]; then
  echo "theme-apply-all: no palette at $PALETTE_FILE, skipping" >&2
  exit 0
fi

# Acquire lock (non-blocking — exit if already held)
exec 9>"$THEME_LOCK"
flock -n 9 || { echo "theme-apply-all: already running" >&2; exit 0; }

apps=(sway waybar swaylock mako ghostty)
applied=0
skipped=0
failed=0

for app in "${apps[@]}"; do
  script="$CONFIG_DIR/$app/scripts/apply-theme"
  if [[ ! -x "$script" ]]; then
    skipped=$((skipped + 1))
    continue
  fi

  if (( check )); then
    if "$script" --check; then
      applied=$((applied + 1))
    else
      echo "theme-apply-all: FAIL $app" >&2
      failed=$((failed + 1))
    fi
  else
    if "$script"; then
      applied=$((applied + 1))
    else
      echo "theme-apply-all: FAIL $app" >&2
      failed=$((failed + 1))
    fi
  fi
done

echo "theme-apply-all: applied=$applied skipped=$skipped failed=$failed" >&2

if (( failed )); then
  exit 1
fi
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x local/dot-local/bin/theme-apply-all`

- [ ] **Step 3: Commit**

Run:
```bash
git add local/dot-local/bin/theme-apply-all
git commit -m "feat(theme): add theme-apply-all orchestrator

Fixed app list, flock concurrency guard, --check support.
Continues on per-app failure, reports summary."
```

---

### Task 7: Update stow-scripts.sh to support lib directories

**Files:**
- Modify: `install/lib/stow-scripts.sh:20-26`

- [ ] **Step 1: Update the lib symlink loop**

In `install/lib/stow-scripts.sh`, replace lines 22-25:

```bash
for lib_file in "${REPO_ROOT}/local/dot-local/lib"/*; do
	if [[ -f "$lib_file" ]]; then
		ln -sf "$lib_file" "${HOME_DIR}/.local/lib/"
	fi
done
```

with:

```bash
for lib_entry in "${REPO_ROOT}/local/dot-local/lib"/*; do
	if [[ -f "$lib_entry" ]]; then
		ln -sf "$lib_entry" "${HOME_DIR}/.local/lib/"
	elif [[ -d "$lib_entry" ]]; then
		ln -sfn "$lib_entry" "${HOME_DIR}/.local/lib/$(basename "$lib_entry")"
	fi
done
```

- [ ] **Step 2: Commit**

Run:
```bash
git add install/lib/stow-scripts.sh
git commit -m "fix(install): support lib subdirectory symlinks in stow-scripts

Directories under local/dot-local/lib/ are now symlinked as
directory symlinks (ln -sfn), enabling lib/theme/render."
```

---

### Task 8: Update bootstrap (finalize.sh)

**Files:**
- Modify: `install/user/finalize.sh:24-26`

- [ ] **Step 1: Replace the thememanager call**

In `install/user/finalize.sh`, replace lines 24-26:

```bash
# Activate theme
info "Setting theme to auto..."
python3 "${REPO_ROOT}/local/thememanager/thememanager" set auto
```

with:

```bash
# Seed palette if no live palette exists, then render themed configs
info "Applying theme from palette..."
THEME_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/theme"
PALETTE_SEED="${XDG_CONFIG_HOME:-$HOME/.config}/thememanager/palette.seed.json"
mkdir -p "$THEME_DATA_DIR"
if [[ ! -f "$THEME_DATA_DIR/palette.json" ]] && [[ -f "$PALETTE_SEED" ]]; then
    cp "$PALETTE_SEED" "$THEME_DATA_DIR/palette.json"
fi
theme-apply-all
```

- [ ] **Step 2: Commit**

Run:
```bash
git add install/user/finalize.sh
git commit -m "refactor(install): replace thememanager bootstrap with palette seed + apply

Bootstrap no longer depends on Python/matugen/color256. Uses committed
palette seed and theme-apply-all orchestrator."
```

---

### Task 9: Strip application logic from thememanager

**Files:**
- Modify: `local/thememanager/thememanager`

- [ ] **Step 1: Update imports — add `fcntl`**

In `local/thememanager/thememanager`, add `import fcntl` to the imports section (after `import json` on line 19):

```python
import fcntl
```

- [ ] **Step 2: Update path constants**

Replace lines 40-46:

```python
HOME = Path.home()
THEME_MANAGER_DIR = Path(
    os.environ.get("THEME_MANAGER_DIR", HOME / ".config" / "thememanager")
)
APP_CONFIG_FILE = THEME_MANAGER_DIR / "apps.json"
PALETTE_FILE = THEME_MANAGER_DIR / "palette.json"
COLOR256_THEMES_DIR = HOME / ".local" / "share" / "themes"
```

with:

```python
HOME = Path.home()
THEME_MANAGER_DIR = Path(
    os.environ.get("THEME_MANAGER_DIR", HOME / ".config" / "thememanager")
)
XDG_DATA_HOME = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local" / "share"))
PALETTE_FILE = XDG_DATA_HOME / "theme" / "palette.json"
COLOR256_THEMES_DIR = HOME / ".local" / "share" / "themes"
```

- [ ] **Step 3: Add `schema_version` to `_build_semantic_palette`**

In the `_build_semantic_palette` function, add `schema_version` to the palette dict. Replace the beginning of the palette dict construction (lines 123-131):

```python
    palette = {
        "theme_name": theme_name,
        "bg": bg,
```

with:

```python
    palette = {
        "schema_version": "1",
        "theme_name": theme_name,
        "bg": bg,
```

- [ ] **Step 4: Remove application methods from ThemeManager class**

Remove these methods entirely from the `ThemeManager` class:
- `_load_app_configs` (lines 204-229)
- `_ensure_home_target` (lines 238-240)
- `_is_path_within` (lines 232-236)
- `_apply_theme` (lines 412-431)
- `_apply_direct` (lines 507-535)
- `_apply_template` (lines 537-575)
- `_reload_apps` (lines 577-593)
- `_run_command` (lines 594-621)

Also remove from `__init__` (line 202):
```python
        self.app_configs = self._load_app_configs()
```

- [ ] **Step 5: Add lock-and-apply method**

Add this method to the `ThemeManager` class (replacing `_apply_theme`):

```python
    def _write_and_apply(self, palette):
        """Write palette atomically under lock, then trigger theme-apply-all."""
        lock_path = os.environ.get("XDG_RUNTIME_DIR", "/tmp") + f"/theme.{os.getuid()}.lock"
        lock_fd = os.open(lock_path, os.O_CREAT | os.O_WRONLY)
        fcntl.flock(lock_fd, fcntl.LOCK_EX)
        try:
            PALETTE_FILE.parent.mkdir(parents=True, exist_ok=True)
            content = json.dumps(palette, indent=2) + "\n"
            if self.dry_run:
                logger.info(f"[dry-run] Would write palette to {PALETTE_FILE}")
            else:
                tmp = PALETTE_FILE.with_suffix(".tmp")
                tmp.write_text(content)
                tmp.rename(PALETTE_FILE)

            if not self.dry_run:
                apply_cmd = shutil.which("theme-apply-all")
                if apply_cmd:
                    logger.info("Running theme-apply-all...")
                    subprocess.run([apply_cmd], check=False)
                else:
                    logger.debug("theme-apply-all not found, skipping apply")
        finally:
            fcntl.flock(lock_fd, fcntl.LOCK_UN)
            os.close(lock_fd)
```

- [ ] **Step 6: Update callers to use `_write_and_apply`**

In `set_theme` method, replace the call `self._apply_theme(palette)` with `self._write_and_apply(palette)`.

In `auto_theme_from_wallpaper` method, replace `self._apply_theme(palette)` with `self._write_and_apply(palette)`.

- [ ] **Step 7: Update `get_current_theme` to use new PALETTE_FILE path**

This method already references `PALETTE_FILE` which was updated in Step 2. No code change needed — just verify it still works.

Run: `python3 local/thememanager/thememanager get`

Expected: prints the current theme name (or "none" if no live palette exists yet).

- [ ] **Step 8: Commit**

Run:
```bash
git add local/thememanager/thememanager
git commit -m "refactor(thememanager): strip application logic, add lock + atomic write

thememanager is now a pure palette producer. Template rendering, app
config writing, and reload behavior are owned by per-app scripts.
Palette writes use flock + atomic rename. theme-apply-all is called
best-effort after palette update."
```

---

### Task 10: Delete removed thememanager files

**Files:**
- Delete: `apps/thememanager/dot-config/thememanager/apps.json`
- Delete: `apps/thememanager/dot-config/thememanager/reload-ghostty.sh`
- Delete: `apps/thememanager/dot-config/thememanager/reload-pinentry-gtk.sh`

- [ ] **Step 1: Remove files**

Run:
```bash
git rm apps/thememanager/dot-config/thememanager/apps.json
git rm apps/thememanager/dot-config/thememanager/reload-ghostty.sh
git rm apps/thememanager/dot-config/thememanager/reload-pinentry-gtk.sh
```

- [ ] **Step 2: Commit**

Run:
```bash
git commit -m "refactor(thememanager): remove apps.json and reload scripts

apps.json is no longer needed — app registration is replaced by the
fixed list in theme-apply-all. Reload logic now lives in per-app
apply-theme scripts."
```

---

### Task 11: Update nvim palette path

**Files:**
- Modify: `apps/nvim/dot-config/nvim/plugin/colors.lua:10`
- Modify: `apps/nvim/dot-config/nvim/lua/custom/theme.lua:166`

- [ ] **Step 1: Update `plugin/colors.lua`**

In `apps/nvim/dot-config/nvim/plugin/colors.lua`, replace line 10:

```lua
  local palette_path = vim.fn.expand("$XDG_CONFIG_HOME/thememanager/palette.json")
```

with:

```lua
  local data_home = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
  local palette_path = data_home .. "/theme/palette.json"
```

- [ ] **Step 2: Update `lua/custom/theme.lua`**

In `apps/nvim/dot-config/nvim/lua/custom/theme.lua`, replace line 166:

```lua
      local palette_path = vim.fn.expand("$XDG_CONFIG_HOME/thememanager/palette.json")
```

with:

```lua
      local data_home = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
      local palette_path = data_home .. "/theme/palette.json"
```

- [ ] **Step 3: Commit**

Run:
```bash
git add apps/nvim/dot-config/nvim/plugin/colors.lua \
        apps/nvim/dot-config/nvim/lua/custom/theme.lua
git commit -m "refactor(nvim): update palette path to XDG_DATA_HOME/theme/

Palette moved from config to data directory as part of theme
decoupling. Both locations guard on file existence."
```

---

### Task 12: End-to-end validation

- [ ] **Step 1: Verify renderer works against the seed palette with each real template**

Run:
```bash
PALETTE=apps/thememanager/dot-config/thememanager/palette.seed.json
RENDER=./local/dot-local/lib/theme/render

echo "=== sway ===" && $RENDER "$PALETTE" apps/sway/dot-config/sway/templates/theme.config.tmpl | head -3
echo "=== waybar ===" && $RENDER "$PALETTE" apps/waybar/dot-config/waybar/templates/style.css.tmpl | head -3
echo "=== swaylock ===" && $RENDER "$PALETTE" apps/swaylock/dot-config/swaylock/templates/config.tmpl | head -3
echo "=== mako ===" && $RENDER "$PALETTE" apps/mako/dot-config/mako/templates/theme.ini.tmpl | head -3
```

Expected: each prints the first 3 lines with colors substituted (no `{{...}}` placeholders remaining).

- [ ] **Step 2: Verify strict mode passes for all templates**

Run:
```bash
PALETTE=apps/thememanager/dot-config/thememanager/palette.seed.json
RENDER=./local/dot-local/lib/theme/render

$RENDER --strict "$PALETTE" apps/sway/dot-config/sway/templates/theme.config.tmpl > /dev/null && echo "sway: OK"
$RENDER --strict "$PALETTE" apps/waybar/dot-config/waybar/templates/style.css.tmpl > /dev/null && echo "waybar: OK"
$RENDER --strict "$PALETTE" apps/swaylock/dot-config/swaylock/templates/config.tmpl > /dev/null && echo "swaylock: OK"
$RENDER --strict "$PALETTE" apps/mako/dot-config/mako/templates/theme.ini.tmpl > /dev/null && echo "mako: OK"
```

Expected: all print OK.

- [ ] **Step 3: Verify thememanager still parses without errors**

Run:
```bash
python3 local/thememanager/thememanager list
python3 local/thememanager/thememanager get
```

Expected: `list` shows available themes, `get` shows current theme or "none".

- [ ] **Step 4: Verify git status is clean (all changes committed)**

Run: `git status`

Expected: only untracked files or clean working tree.

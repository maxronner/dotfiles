# Install Architecture Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the install system into `system/` (privileged) and `user/` (unprivileged) flows with clear boundary enforcement.

**Architecture:** Phase scripts in `system/` and `user/` compose step scripts from `lib/`. The justfile exposes `bootstrap`, `system`, `user`, `extras`, and `unlink` as the public API. Old `phases/` and numbered scripts are removed after migration.

**Tech Stack:** Bash, GNU Stow, just, systemd, pacman/yay

**Spec:** `docs/superpowers/specs/2026-04-10-install-architecture-redesign.md`

---

### Task 1: Create directory layout and move common.sh

**Files:**
- Move: `install/common.sh` → `install/lib/common.sh`
- Create: `install/system/` (empty dir)
- Create: `install/user/` (empty dir)
- Create: `install/extras/` (exists, but needs reorganization)

- [ ] **Step 1: Create the new directory structure**

```bash
mkdir -p install/lib install/system install/user install/extras
```

- [ ] **Step 2: Move common.sh into lib/**

```bash
git mv install/common.sh install/lib/common.sh
```

- [ ] **Step 3: Commit**

```bash
git add install/lib/ install/system/ install/user/ install/extras/
git commit -m "chore: create new install directory layout and move common.sh to lib/"
```

---

### Task 2: Create lib/preflight.sh

**Files:**
- Create: `install/lib/preflight.sh`
- Reference: `install/phases/preflight.sh` (source material)

- [ ] **Step 1: Write lib/preflight.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

info "Initializing git submodules..."
if ! git -C "${REPO_ROOT}" submodule update --init --recursive; then
  warn "Failed to fetch submodules (network issue?), continuing with existing state"
fi
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x install/lib/preflight.sh
```

- [ ] **Step 3: Commit**

```bash
git add install/lib/preflight.sh
git commit -m "chore: add lib/preflight.sh for git submodule initialization"
```

---

### Task 3: Move numbered scripts into lib/

Move all numbered implementation scripts into `lib/`, drop numeric prefixes, rename `50-stow-system.sh` to `stow-apps.sh`. Update each script's `source` line from `common.sh` to `lib/common.sh`.

**Files:**
- Move: `install/10-install-terminal.sh` → `install/lib/install-terminal.sh`
- Move: `install/11-install-tpm.sh` → `install/lib/install-tpm.sh`
- Move: `install/30-install-yay.sh` → `install/lib/install-yay.sh`
- Move: `install/31-install-aur.sh` → `install/lib/install-aur.sh`
- Move: `install/40-enable-system-services.sh` → `install/lib/enable-system-services.sh`
- Move: `install/41-enable-user-services.sh` → `install/lib/enable-user-services.sh`
- Move: `install/41-setup-timesyncd.sh` → `install/lib/setup-timesyncd.sh`
- Move: `install/50-stow-system.sh` → `install/lib/stow-apps.sh`
- Move: `install/51-stow-device.sh` → `install/lib/stow-device.sh`
- Move: `install/52-init-nvim.sh` → `install/lib/init-nvim.sh`
- Move: `install/60-configure-sway-desktop.sh` → `install/lib/configure-sway-desktop.sh`
- Move: `install/61-create-sway-config-dir.sh` → `install/lib/create-sway-config-dir.sh`
- Move: `install/phases/stow-scripts.sh` → `install/lib/stow-scripts.sh`
- Move: `install/phases/stow-themes.sh` → `install/lib/stow-themes.sh`

- [ ] **Step 1: Move and rename all scripts**

```bash
git mv install/10-install-terminal.sh install/lib/install-terminal.sh
git mv install/11-install-tpm.sh install/lib/install-tpm.sh
git mv install/30-install-yay.sh install/lib/install-yay.sh
git mv install/31-install-aur.sh install/lib/install-aur.sh
git mv install/40-enable-system-services.sh install/lib/enable-system-services.sh
git mv install/41-enable-user-services.sh install/lib/enable-user-services.sh
git mv install/41-setup-timesyncd.sh install/lib/setup-timesyncd.sh
git mv install/50-stow-system.sh install/lib/stow-apps.sh
git mv install/51-stow-device.sh install/lib/stow-device.sh
git mv install/52-init-nvim.sh install/lib/init-nvim.sh
git mv install/60-configure-sway-desktop.sh install/lib/configure-sway-desktop.sh
git mv install/61-create-sway-config-dir.sh install/lib/create-sway-config-dir.sh
git mv install/phases/stow-scripts.sh install/lib/stow-scripts.sh
git mv install/phases/stow-themes.sh install/lib/stow-themes.sh
```

- [ ] **Step 2: Update source lines in all moved scripts**

Every script that had `source "${SCRIPT_DIR}/common.sh"` now needs `source "${SCRIPT_DIR}/common.sh"` (unchanged — they're now in the same directory as common.sh).

Every script that had `source "${SCRIPT_DIR}/../common.sh"` (the former phases/ scripts) now needs `source "${SCRIPT_DIR}/common.sh"` since they're now alongside common.sh in lib/.

Update `install/lib/stow-scripts.sh`:
```
old: source "${SCRIPT_DIR}/../common.sh"
new: source "${SCRIPT_DIR}/common.sh"
```

Update `install/lib/stow-themes.sh`:
```
old: source "${SCRIPT_DIR}/../common.sh"
new: source "${SCRIPT_DIR}/common.sh"
```

Also in `install/lib/stow-scripts.sh`, update the call to stow-themes.sh:
```
old: bash "${SCRIPT_DIR}/stow-themes.sh"
new: bash "${SCRIPT_DIR}/stow-themes.sh"
```
(No change needed — both are now in the same directory.)

- [ ] **Step 3: Remove the old wrapper install/40-enable-systemd-services.sh**

This was a wrapper calling the two split files. It's no longer needed — phase scripts will call lib/ directly.

```bash
git rm install/40-enable-systemd-services.sh
```

- [ ] **Step 4: Commit**

```bash
git add -A install/lib/ install/phases/
git commit -m "chore: move numbered scripts and phase helpers into install/lib/"
```

---

### Task 4: Move specifics/ into install/specifics/

**Files:**
- Move: `install/specifics/setup-laptop.sh` → `install/specifics/setup-laptop.sh` (already there)
- Update source lines if needed

The specifics/ directory is already at `install/specifics/`. The scripts source `"${SCRIPT_DIR}/../common.sh"` which currently resolves to `install/common.sh`. After Task 1 moved common.sh to `install/lib/common.sh`, we need to update these paths.

- [ ] **Step 1: Update source lines in all specifics scripts**

Update `install/specifics/setup-laptop.sh`:
```
old: source "${SCRIPT_DIR}/../common.sh"
new: source "${SCRIPT_DIR}/../lib/common.sh"
```

Update `install/specifics/setup-workstation.sh`:
```
old: source "${SCRIPT_DIR}/../common.sh"
new: source "${SCRIPT_DIR}/../lib/common.sh"
```

Update `install/specifics/setup-swayfx-nvidia.sh`:
```
old: source "$ROOT_DIR/common.sh"
new: source "$ROOT_DIR/lib/common.sh"
```

- [ ] **Step 2: Commit**

```bash
git add install/specifics/
git commit -m "fix: update specifics/ source paths to lib/common.sh"
```

---

### Task 5: Write system/packages.sh

**Files:**
- Create: `install/system/packages.sh`

This phase script composes `lib/install-terminal.sh`, `lib/install-yay.sh`, and `lib/install-aur.sh`. It must NOT include TPM install or `$HOME` mutations.

- [ ] **Step 1: Write the phase script**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

# Install repo packages (pacman)
bash "${SCRIPT_DIR}/../lib/install-terminal.sh" "$PROFILE"

# Bootstrap yay if absent, then install AUR packages
bash "${SCRIPT_DIR}/../lib/install-yay.sh"
bash "${SCRIPT_DIR}/../lib/install-aur.sh" "$PROFILE"
```

- [ ] **Step 2: Remove $HOME mutations from lib/install-terminal.sh**

Remove the vim spell and zsh lines from `install/lib/install-terminal.sh`. These will move to `user/finalize.sh` in Task 8.

Current end of file:
```bash
install_repo_packages "${PKGS[@]}"

info "Symlinking vim-spell-sv to $HOME/.local/share/nvim/site/spell"
mkdir -p ~/.local/share/nvim/site/spell
stow -d /usr/share/vim/vimfiles -t "$HOME/.local/share/nvim/site/spell" spell

mkdir -p ~/.local/share/zsh
```

Replace with:
```bash
install_repo_packages "${PKGS[@]}"
```

- [ ] **Step 3: Commit**

```bash
git add install/system/packages.sh install/lib/install-terminal.sh
git commit -m "feat: add system/packages.sh phase, remove HOME mutations from install-terminal"
```

---

### Task 6: Write system/config.sh

**Files:**
- Create: `install/system/config.sh`

Composes `lib/enable-system-services.sh`, `lib/setup-timesyncd.sh`, and `lib/configure-sway-desktop.sh`.

- [ ] **Step 1: Write the phase script**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# Enable system-level systemd services
bash "${SCRIPT_DIR}/../lib/enable-system-services.sh"

# Configure NTP and timezone
bash "${SCRIPT_DIR}/../lib/setup-timesyncd.sh"

# Configure sway desktop entry (XDG, nvidia detection)
bash "${SCRIPT_DIR}/../lib/configure-sway-desktop.sh"
```

- [ ] **Step 2: Commit**

```bash
git add install/system/config.sh
git commit -m "feat: add system/config.sh phase for OS-level configuration"
```

---

### Task 7: Write system/device.sh

**Files:**
- Create: `install/system/device.sh`

Dispatches to `specifics/setup-{env}.sh`. Reuses logic from old `phases/device.sh`.

- [ ] **Step 1: Write the phase script**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

if [[ -z "$PROFILE" ]]; then
    info "No device profile specified, skipping device setup."
    exit 0
fi

SETUP_SCRIPT="${SCRIPT_DIR}/../specifics/setup-${PROFILE}.sh"

if [[ ! -f "$SETUP_SCRIPT" ]]; then
    warn "No device setup script for profile: ${PROFILE}"
    exit 0
fi

info "Running device setup for profile: ${PROFILE}..."
bash "$SETUP_SCRIPT"
```

- [ ] **Step 2: Commit**

```bash
git add install/system/device.sh
git commit -m "feat: add system/device.sh phase for device-profile dispatch"
```

---

### Task 8: Write user/dotfiles.sh

**Files:**
- Create: `install/user/dotfiles.sh`

Composes `lib/stow-apps.sh` and `lib/stow-device.sh`.

- [ ] **Step 1: Write the phase script**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

PROFILE=""
resolve_profile "${1:-}" PROFILE

# Stow app dotfiles to $HOME (skips nvim — opt-in via extras)
bash "${SCRIPT_DIR}/../lib/stow-apps.sh"

# Stow device-specific overrides if profile provided
bash "${SCRIPT_DIR}/../lib/stow-device.sh" "$PROFILE"
```

- [ ] **Step 2: Commit**

```bash
git add install/user/dotfiles.sh
git commit -m "feat: add user/dotfiles.sh phase for HOME dotfile deployment"
```

---

### Task 9: Write user/finalize.sh

**Files:**
- Create: `install/user/finalize.sh`

Composes `lib/stow-themes.sh`, `lib/stow-scripts.sh`, `lib/create-sway-config-dir.sh`, `lib/install-tpm.sh`, and adds the `$HOME` mutations moved from `install-terminal.sh`.

- [ ] **Step 1: Write the phase script**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# Stow themes and symlink local scripts/libs
bash "${SCRIPT_DIR}/../lib/stow-scripts.sh"

# Create sway config directory if absent
bash "${SCRIPT_DIR}/../lib/create-sway-config-dir.sh"

# Install TPM if absent
bash "${SCRIPT_DIR}/../lib/install-tpm.sh"

# Prepare user-facing runtime layout for installed software
info "Setting up vim spell symlinks..."
mkdir -p "${HOME_DIR}/.local/share/nvim/site/spell"
stow -d /usr/share/vim/vimfiles -t "${HOME_DIR}/.local/share/nvim/site/spell" spell

info "Creating zsh data directory..."
mkdir -p "${HOME_DIR}/.local/share/zsh"

# Activate theme
info "Setting theme to auto..."
python3 "${REPO_ROOT}/local/thememanager/thememanager" set auto
```

Note: `lib/stow-scripts.sh` already calls `lib/stow-themes.sh` internally, so themes are handled.

- [ ] **Step 2: Commit**

```bash
git add install/user/finalize.sh
git commit -m "feat: add user/finalize.sh phase for post-deploy user setup"
```

---

### Task 10: Write user/services.sh

**Files:**
- Create: `install/user/services.sh`

Explicit managed unit list only — no auto-discovery.

- [ ] **Step 1: Write the phase script**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

USER_SERVICES=(
  mako.service
  syncthing.service
)

info "Enabling managed user services..."
for unit in "${USER_SERVICES[@]}"; do
  if ! systemctl --user cat "$unit" &>/dev/null; then
    error "Unit file not found: ${unit} — is the package installed and dotfiles stowed?"
    exit 1
  fi
done

systemctl --user enable --now "${USER_SERVICES[@]}"
success "User services enabled."
```

- [ ] **Step 2: Commit**

```bash
git add install/user/services.sh
git commit -m "feat: add user/services.sh phase with explicit managed unit list"
```

---

### Task 11: Write extras

**Files:**
- Create: `install/extras/dev.sh`
- Create: `install/extras/nvim.sh`
- Create: `install/extras/ly.sh`
- Move: `install/extras/unstow-dotfiles.sh` → `install/extras/unlink.sh`

- [ ] **Step 1: Write extras/dev.sh**

```bash
#!/usr/bin/env bash
# scope: system
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

pkg_file="${REPO_ROOT}/optional/development/pkg.txt"

if [[ ! -f "$pkg_file" ]]; then
  error "Development package manifest not found: ${pkg_file}"
  exit 1
fi

mapfile -t PKGS < <(grep -v '^\s*#' "$pkg_file" | grep -v '^\s*$' | grep -v '^aur:' | sort -u)

info "Installing development packages..."
install_repo_packages "${PKGS[@]}"
```

- [ ] **Step 2: Write extras/nvim.sh**

```bash
#!/usr/bin/env bash
# scope: user
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

bash "${SCRIPT_DIR}/../lib/init-nvim.sh"
```

- [ ] **Step 3: Write extras/ly.sh**

Adapted from old `install/22-setup-ly.sh`:

```bash
#!/usr/bin/env bash
# scope: system
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

info "Configuring ly..."
LY_CONFIG=/etc/ly/config.ini
sudo sed -i "s/^[[:space:]]*animation[[:space:]]*=.*/animation = matrix/" "$LY_CONFIG"
sudo sed -i "s/^[[:space:]]*clock[[:space:]]*=.*/clock = %c/" "$LY_CONFIG"
sudo sed -i "s/^[[:space:]]*vi_mode[[:space:]]*=.*/vi_mode = true/" "$LY_CONFIG"

info "Overriding ly service..."
LY_OVERRIDE_DIR=/etc/systemd/system/ly.service.d
LY_OVERRIDE_FILE="$LY_OVERRIDE_DIR/override.conf"
sudo mkdir -p "$LY_OVERRIDE_DIR"
echo "[Service]" | sudo tee "$LY_OVERRIDE_FILE" > /dev/null
echo "StandardOutput=null" | sudo tee -a "$LY_OVERRIDE_FILE" > /dev/null
echo "StandardError=null" | sudo tee -a "$LY_OVERRIDE_FILE" > /dev/null
sudo systemctl daemon-reexec

info "Enabling ly service..."
sudo systemctl enable --now ly@tty2.service
sudo systemctl disable --now getty@tty2.service

success "ly configured and enabled."
```

- [ ] **Step 4: Move and update unstow-dotfiles.sh to extras/unlink.sh**

```bash
git mv install/extras/unstow-dotfiles.sh install/extras/unlink.sh
```

Update the source line in `install/extras/unlink.sh`:
```
old: source "${SCRIPT_DIR}/../common.sh"
new: source "${SCRIPT_DIR}/../lib/common.sh"
```

Add scope declaration at the top (after shebang):
```
old: #!/usr/bin/env bash
new: #!/usr/bin/env bash
     # scope: user
```

- [ ] **Step 5: Commit**

```bash
git add install/extras/
git commit -m "feat: add extras (dev, nvim, ly) and rename unstow-dotfiles to unlink"
```

---

### Task 12: Update lib/install-terminal.sh source path and lib/init-nvim.sh source path

After moving common.sh to lib/, the scripts that were already at the same level (`install/*.sh`) now have correct relative paths since they're all in `lib/`. But `lib/init-nvim.sh` still references `"${SCRIPT_DIR}/common.sh"` which is correct.

However, `install/lib/stow-apps.sh` (formerly `50-stow-system.sh`) and other scripts that sourced `"${SCRIPT_DIR}/common.sh"` — this is still correct since they're now colocated with `common.sh` in `lib/`.

The scripts that need path updates are those that sourced via `"${SCRIPT_DIR}/../common.sh"` — those were the phase scripts that moved to lib/ in Task 3.

- [ ] **Step 1: Verify all lib/ scripts have correct source path**

Run: `grep -n 'source.*common' install/lib/*.sh`

Every script in `install/lib/` should have `source "${SCRIPT_DIR}/common.sh"`. Fix any that have `../common.sh`.

- [ ] **Step 2: Commit if any fixes needed**

```bash
git add install/lib/
git commit -m "fix: ensure all lib/ scripts source common.sh with correct relative path"
```

---

### Task 13: Update the justfile

**Files:**
- Modify: `justfile`

- [ ] **Step 1: Replace the justfile content**

```makefile
bootstrap env='':
  @bash install/lib/preflight.sh
  just system {{env}}
  just user {{env}}

system env='':
  @bash install/system/packages.sh {{env}}
  @bash install/system/config.sh {{env}}
  @bash install/system/device.sh {{env}}

user env='':
  @bash install/lib/preflight.sh
  @bash install/user/dotfiles.sh {{env}}
  @bash install/user/finalize.sh
  @bash install/user/services.sh

extras name:
  #!/usr/bin/env bash
  if [ ! -f install/extras/{{name}}.sh ]; then echo "Unknown extra: {{name}}"; exit 1; fi
  bash install/extras/{{name}}.sh

unlink env='':
  @bash install/extras/unlink.sh {{env}}

lint:
  @missing=0; \
  for dir in "{{justfile_directory()}}"/apps/*/ "{{justfile_directory()}}"/system/*/ "{{justfile_directory()}}"/optional/*/ "{{justfile_directory()}}"/devices/*/; do \
    if [ ! -f "$dir/pkg.txt" ]; then \
      echo "MISSING pkg.txt: $dir"; \
      missing=1; \
    fi; \
  done; \
  [ $missing -eq 0 ] && echo "All packages have pkg.txt" || exit 1
```

- [ ] **Step 2: Commit**

```bash
git add justfile
git commit -m "feat: update justfile with system/user/extras targets"
```

---

### Task 14: Remove old phases/ and numbered scripts

**Files:**
- Remove: `install/phases/activate.sh`
- Remove: `install/phases/apply-home.sh`
- Remove: `install/phases/apply-hooks.sh`
- Remove: `install/phases/bootstrap.sh`
- Remove: `install/phases/device.sh`
- Remove: `install/phases/packages-aur.sh`
- Remove: `install/phases/packages.sh`
- Remove: `install/phases/preflight.sh`
- Remove: `install/phases/stow-dotfiles.sh`
- Remove: `install/phases/unstow.sh`
- Remove: `install/20-install-dev.sh`
- Remove: `install/22-setup-ly.sh`

- [ ] **Step 1: Verify no remaining references to old paths**

```bash
grep -r 'install/phases/' justfile install/
grep -r 'install/[0-9][0-9]-' justfile install/
```

Both should return no matches (other than in the files being deleted).

- [ ] **Step 2: Remove old files**

```bash
git rm install/phases/activate.sh
git rm install/phases/apply-home.sh
git rm install/phases/apply-hooks.sh
git rm install/phases/bootstrap.sh
git rm install/phases/device.sh
git rm install/phases/packages-aur.sh
git rm install/phases/packages.sh
git rm install/phases/preflight.sh
git rm install/phases/stow-dotfiles.sh
git rm install/phases/unstow.sh
git rm install/20-install-dev.sh
git rm install/22-setup-ly.sh
```

- [ ] **Step 3: Remove empty phases/ directory**

```bash
rmdir install/phases
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove old phases/ directory and standalone numbered scripts"
```

---

### Task 15: Final verification

- [ ] **Step 1: Verify directory structure matches spec**

```bash
find install/ -type f -name '*.sh' | sort
```

Expected output:
```
install/extras/dev.sh
install/extras/ly.sh
install/extras/nvim.sh
install/extras/unlink.sh
install/lib/common.sh
install/lib/configure-sway-desktop.sh
install/lib/create-sway-config-dir.sh
install/lib/enable-system-services.sh
install/lib/enable-user-services.sh
install/lib/init-nvim.sh
install/lib/install-aur.sh
install/lib/install-terminal.sh
install/lib/install-tpm.sh
install/lib/install-yay.sh
install/lib/preflight.sh
install/lib/setup-timesyncd.sh
install/lib/stow-apps.sh
install/lib/stow-device.sh
install/lib/stow-scripts.sh
install/lib/stow-themes.sh
install/specifics/setup-laptop.sh
install/specifics/setup-swayfx-nvidia.sh
install/specifics/setup-workstation.sh
install/system/config.sh
install/system/device.sh
install/system/packages.sh
install/user/dotfiles.sh
install/user/finalize.sh
install/user/services.sh
```

- [ ] **Step 2: Verify no sudo in user/ scripts**

```bash
grep -r 'sudo' install/user/
```

Expected: no matches.

- [ ] **Step 3: Verify no $HOME writes in system/ scripts**

```bash
grep -rE '\$HOME|~/|HOME_DIR' install/system/
```

Expected: no matches (system scripts delegate to lib/ which may reference HOME_DIR for read-only purposes like resolve_profile, but the system phase scripts themselves should not).

- [ ] **Step 4: Verify all source paths resolve**

```bash
for f in install/lib/*.sh install/system/*.sh install/user/*.sh install/extras/*.sh install/specifics/*.sh; do
  grep -q 'source' "$f" || continue
  echo "--- $f ---"
  grep 'source' "$f"
done
```

Manually verify each source path resolves correctly given the file's location.

- [ ] **Step 5: Verify justfile targets parse**

```bash
just --list
```

Expected output should show: `bootstrap`, `system`, `user`, `extras`, `unlink`, `lint`.

- [ ] **Step 6: Verify scope declarations in extras**

```bash
head -2 install/extras/*.sh
```

Each extra should have `# scope: system` or `# scope: user` on line 2.

- [ ] **Step 7: Verify lib/enable-user-services.sh no longer has auto-discovery**

This file was moved as-is in Task 3 but still contains the old auto-discovery logic. It needs to be stripped down since `user/services.sh` now handles service enablement directly with an explicit list.

If `lib/enable-user-services.sh` still contains auto-discovery code, it is now dead code. Either:
- Remove the file entirely (since `user/services.sh` replaced its functionality), or
- Strip it to just the explicit enable call if any other script references it

Check:
```bash
grep -r 'enable-user-services' install/
```

If nothing references it, remove it:
```bash
git rm install/lib/enable-user-services.sh
git commit -m "chore: remove unused lib/enable-user-services.sh (replaced by user/services.sh)"
```

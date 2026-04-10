# Install Architecture Redesign

## Goal

Separate the install system into two distinct execution flows based on privilege boundary:

- **System flow** — requires sudo, installs packages, configures OS-level settings
- **User flow** — no sudo, deploys dotfiles, enables user services, runs post-deploy setup

A composite `bootstrap` target runs both. Optional extras are self-contained add-ons.

## Invocation Model

Scripts are run as the invoking user, never via `sudo just ...`. Individual privileged commands inside system scripts use `sudo` as needed. This preserves the invoking user's identity for AUR builds, `$HOME` resolution, and `systemctl --user` operations.

## Directory Structure

```
install/
  lib/                          # shared utilities and narrowly scoped step scripts
    common.sh                   # logging, package helpers, profile resolution
    preflight.sh                # git submodule init
    install-terminal.sh         # pacman package install from pkg.txt
    install-yay.sh              # bootstrap yay AUR helper
    install-aur.sh              # AUR package install from pkg.txt
    enable-system-services.sh   # systemctl enable for system units
    setup-timesyncd.sh          # NTP config + timezone
    configure-sway-desktop.sh   # sway .desktop entry (XDG, nvidia)
    stow-apps.sh                # stow apps/ to $HOME
    stow-device.sh              # stow devices/{env} to $HOME
    stow-scripts.sh             # symlink local scripts/libs to ~/.local/
    stow-themes.sh              # symlink theme assets to ~/.local/share/themes/
    create-sway-config-dir.sh   # ensure ~/.config/sway/scripts/ exists
    enable-user-services.sh     # systemctl --user enable for user units
    install-tpm.sh              # clone tmux plugin manager to $HOME
  system/                       # privileged phase scripts
    packages.sh
    config.sh
    device.sh
  user/                         # unprivileged phase scripts
    dotfiles.sh
    finalize.sh
    services.sh
  extras/                       # optional, self-contained add-ons
    dev.sh                      # scope: system
    nvim.sh                     # scope: user
    ly.sh                       # scope: system
    unlink.sh                   # scope: user
  specifics/                    # device-profile scripts
    setup-laptop.sh             # scope: system
    setup-workstation.sh        # scope: system
    setup-swayfx-nvidia.sh      # scope: system
```

## Execution Model

### Just Targets

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
  @bash install/extras/{{name}}.sh

unlink env='':
  @bash install/extras/unlink.sh {{env}}

lint:
  # validate all package dirs have pkg.txt
```

Note: `preflight` runs in both `bootstrap` and `user`. This is intentional — it is idempotent, and standalone `just user` must remain safe without assuming `just system` ran first. The duplicate is acceptable for simplicity.

### Target Graph

```
bootstrap [env]
  |
  +-- preflight
  +-- system [env]
  |     +-- system/packages.sh [env]
  |     +-- system/config.sh [env]
  |     +-- system/device.sh [env]
  |           +-- specifics/setup-{env}.sh (if exists)
  |
  +-- user [env]
        +-- preflight (idempotent, safe to rerun)
        +-- user/dotfiles.sh [env]
        +-- user/finalize.sh
        +-- user/services.sh
```

### Ordering Dependencies

1. `preflight` runs before anything relying on repo state
2. `system/packages.sh` before `system/config.sh` (services must be installed before enabled)
3. `system/config.sh` before `system/device.sh` (base config before device-specific overrides)
4. `user/dotfiles.sh` before `user/finalize.sh` (stow before post-stow setup)
5. `user/finalize.sh` before `user/services.sh` (deploy assets before activating units that may depend on them)

## Phase Contracts

### install/lib/preflight.sh

**Purpose:** Prepare repository state for installation.

**Inputs:** None.

**Effects:** Initializes git submodules. Tolerates network errors gracefully.

**Idempotency:** Safe to run repeatedly.

**Sudo:** No.

---

### install/system/packages.sh

**Purpose:** Install all machine-scoped software.

**Inputs:** Optional `env` profile name.

**Effects:**
- Installs repo packages from all matching `pkg.txt` files via pacman
- Bootstraps yay if absent
- Installs AUR packages from all matching `pkg.txt` files via yay

**Idempotency:** Safe to run repeatedly. Package managers handle already-installed packages.

**Sudo:** Yes (pacman requires sudo). AUR builds run as the invoking user via yay/makepkg; only the final package install step elevates. This is a cross-boundary workflow — the outcome is machine-wide package installation, but AUR building intentionally runs unprivileged.

**Must not:** Deploy dotfiles or modify `$HOME`. User-facing runtime layout (e.g., vim spell symlinks, `~/.local/share/zsh`) belongs in `user/finalize.sh`.

---

### install/system/config.sh

**Purpose:** Configure OS-level settings and services.

**Inputs:** Optional `env` profile name (unused currently, reserved for future per-device config).

**Effects:**
- Enables system systemd services (systemd-resolved, systemd-timesyncd, systemd-tmpfiles-clean.timer)
- Configures timesyncd NTP and timezone
- Modifies sway desktop entry for XDG_CURRENT_DESKTOP and nvidia detection

**Idempotency:** Safe to run repeatedly.

**Sudo:** Yes (systemctl, timedatectl, sed on /usr/share/).

**Must not:** Enable user-scoped services or modify `$HOME`.

**Future seam:** Sway desktop entry modification may split into a separate `system/desktop.sh` if desktop-specific config grows.

---

### install/system/device.sh

**Purpose:** Run device-profile-specific system configuration.

**Inputs:** Optional `env` profile name.

**Effects:** Dispatches to `specifics/setup-{env}.sh` if the profile exists. No-op if no profile given or profile not found.

**Idempotency:** Depends on specific device script, but all current ones are safe to rerun.

**Sudo:** Yes (delegated to specifics scripts).

**Must not:** Perform user-scoped dotfile operations. If user-specific env behavior is needed, that belongs in `user/dotfiles.sh`.

---

### install/user/dotfiles.sh

**Purpose:** Deploy user configuration into `$HOME` via stow.

**Inputs:** Optional `env` profile name.

**Effects:**
- Stows all `apps/` directories to `$HOME` (skips nvim, which is opt-in via extras)
- Stows `devices/{env}/` overrides if env provided

**Idempotency:** Safe to run repeatedly. Stow handles existing symlinks.

**Sudo:** No.

**Must not:** Install packages or modify system state.

---

### install/user/finalize.sh

**Purpose:** Post-deploy user setup in `$HOME`. Prepares user-facing runtime layout for installed software.

**Inputs:** Existing stowed dotfiles. Network access only if TPM is missing.

**Effects:**
- Stow themes to `~/.local/share/themes/`
- Symlink local scripts to `~/.local/bin/`
- Symlink local libs to `~/.local/lib/`
- Create `~/.config/sway/scripts/` if absent
- Clone TPM into `$HOME` if absent
- Set up vim spell symlinks
- Create `~/.local/share/zsh`
- Run `thememanager set auto`

**Idempotency:** Safe to run repeatedly.

**Sudo:** No.

**Must not:** Modify system state or require privilege escalation.

---

### install/user/services.sh

**Purpose:** Enable user-scoped systemd services and timers.

**Inputs:** None.

**Effects:** Enables explicit list of user services and timers via `systemctl --user enable --now`. Fails with a clear message if an expected unit file is missing.

**Managed units:**
- `mako.service`
- `syncthing.service`

**Idempotency:** Safe to run repeatedly.

**Sudo:** No.

**Must not:** Enable system-scoped units. Discovery is explicit list only — no auto-enable of all units found in `~/.config/systemd/user/`. New units are added to the managed list when their app is added to the repo.

---

### install/extras/dev.sh

**Scope:** System.

**Purpose:** Install development packages from `optional/development/pkg.txt`.

**Sudo:** Yes (pacman).

---

### install/extras/nvim.sh

**Scope:** User.

**Purpose:** Initialize nvim git submodule and stow nvim config to `$HOME`.

**Sudo:** No.

---

### install/extras/ly.sh

**Scope:** System.

**Purpose:** Configure ly login manager (animation, vi mode, systemd override, enable service).

**Sudo:** Yes (systemctl, tee, sed on /etc/).

---

### install/extras/unlink.sh

**Scope:** User.

**Purpose:** Remove managed filesystem links. This is the reverse of the link-deployment operations in `user/dotfiles.sh` and `user/finalize.sh` — it is not a full reversal of the entire user flow.

**Inputs:** Optional `env` profile name.

**Effects:**
- Unstows all `apps/` directories
- Unstows `devices/{env}/` if env provided
- Removes manually-linked scripts from `~/.local/bin/`
- Removes manually-linked theme assets from `~/.local/share/themes/`

**Does not:** Disable user services, remove TPM, undo directory creation, or reverse system-level changes.

**Sudo:** No.

## Boundary Model

### System flow may:
- Install packages
- Write under `/etc`, `/usr`, `/var`
- Enable system units
- Call device-specific system scripts
- Read repo files

### System flow may not:
- Write under `$HOME`
- Enable `systemctl --user`
- Stow or symlink user config

### User flow may:
- Write under `$HOME`
- Stow dotfiles
- Enable `systemctl --user`
- Run user-scoped post-setup hooks

### User flow may not:
- Call `sudo`
- Install machine packages
- Mutate `/etc` or `/usr`

## Invariants

1. **No `user/*` script may require sudo.** If a user-flow script needs privilege escalation, it belongs in `system/` or `extras/` with declared system scope.
2. **No `system/*` script may mutate user dotfiles in `$HOME`.** System scripts install software and configure the OS; they do not deploy user config.
3. **Every `extras/` script must declare its scope** (`system` or `user`) as a comment at the top of the file.
4. **`lib/` contains shared utilities and narrowly scoped step scripts** composed by phase scripts. Nothing in `lib/` is a user-facing phase or top-level install flow.
5. **`unlink` only removes managed links** — symlinks explicitly created by this repo's stow and manual linking operations.
6. **All scripts use `set -euo pipefail`.** Fail fast on errors.
7. **All scripts source `lib/common.sh`** for logging and shared utilities.

## Decision Rule for New Scripts

- Does it modify machine state outside `$HOME` or require sudo? -> `system/`
- Does it deploy or activate user state in `$HOME`? -> `user/`
- Is it optional rather than part of the baseline? -> `extras/`
- Is it shared plumbing, not a user-invoked phase? -> `lib/`

## Error Handling

- All scripts use `set -euo pipefail` — fail fast, no partial silent progress.
- Logging uses `info`, `success`, `warn`, `error` from `lib/common.sh`.
- "No-op if absent" conditions (e.g., no device profile, no AUR packages) are reported via `warn` and exit cleanly.
- `user/services.sh` fails with a clear message if an expected unit file is missing, rather than silently skipping.

## Migration Plan

Phase wrappers first to establish the new public API, then refactor internals behind stable entry points:

1. Create directory layout (`lib/`, `system/`, `user/`, `extras/`, `specifics/`)
2. Extract `lib/common.sh` and `lib/preflight.sh`
3. Write new phase scripts (`system/packages.sh`, `system/config.sh`, `system/device.sh`, `user/dotfiles.sh`, `user/finalize.sh`, `user/services.sh`) as wrappers calling existing numbered scripts
4. Move and rename numbered scripts into `lib/` behind those wrappers (drop numeric prefixes, rename `stow-system.sh` -> `stow-apps.sh`)
5. Move `$HOME` mutations (vim spell symlinks, `~/.local/share/zsh`) from old `install-terminal.sh` into `user/finalize.sh`
6. Write `extras/dev.sh`, `extras/nvim.sh`, `extras/ly.sh`, `extras/unlink.sh`
7. Move `specifics/` into new location
8. Update justfile to new targets
9. Narrow `user/services.sh` to explicit unit list (remove auto-discovery)
10. Remove old `phases/` directory and old numbered scripts
11. Verify all flows: `just bootstrap`, `just system`, `just user`, `just system laptop`, `just user laptop`, `just extras dev`, `just extras nvim`, `just unlink laptop`

### Verification Criteria

For each flow, verify:
- No unexpected sudo prompt in `user`
- No `$HOME` mutations in `system`
- Rerun is clean and idempotent
- Missing env profile is a clean no-op with warning
- Missing optional package lists are a clean no-op with warning

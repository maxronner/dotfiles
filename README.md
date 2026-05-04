# dotfiles

A collection of my public dotfiles.

## Overview

This repository contains my system configuration, application settings, and installation scripts organized by category:

- **`apps/`** - Application-specific configurations (e.g., Neovim via git submodule)
- **`system/`** - System-level dotfiles and settings
- **`devices/`** - Device-specific configurations
- **`optional/`** - Optional configurations and tweaks
- **`local/`** - Local machine-specific settings
- **`tools/`** - Source modules for heavier local tools used by the dotfiles
- **`install/`** - Installation scripts organized by privilege boundary
  - **`lib/`** - Shared utilities and step scripts
  - **`system/`** - Privileged phases (packages, system config, device setup)
  - **`user/`** - Unprivileged phases (dotfiles, user services, post-deploy setup)
  - **`extras/`** - Optional add-ons (dev tools, nvim, ly)
  - **`specifics/`** - Device-profile scripts

Package ownership lives in `pkg.txt` Package Manifests next to the app, system group, device profile, or optional add-on that needs the packages. Repository packages are written as plain names; AUR packages use `aur:<name>`.

## Usage

This project uses [just](https://github.com/casey/just) as a task runner. Supported commands:

```bash
just bootstrap [env]      # Full setup: system + user
just system [env]         # Privileged: packages, system config, device setup
just user [env]           # Unprivileged: dotfiles, user services, post-deploy
just user-with-tools [env] # User install, package-install local tools, then verify
just extra <name>        # Optional add-ons (dev, nvim, ly)
just install-tools       # Package-install local tools with uv or pipx
just verify-tools        # Verify local tool commands are callable
just tool-status         # Show whether tools resolve to installed commands or repo fallback
just doctor              # Run lint, tool tests, verification, and tool status
just ci                  # Run non-mutating repo checks
just post-user-check     # Run checks expected after user install/stow
just unlink [env]         # Remove managed symlinks
just lint                 # Validate package manifests
just test-tools           # Test local tool modules and theme adapters
```

## Local Tool Packaging

`thememanager` is released from the standalone checkout at `~/code/thememanager`.
When that checkout and tag `v0.1.0` exist, `just install-tools` installs from
the tagged release:

```bash
git+file:///home/max/code/thememanager@v0.1.0
```

For local development overrides, set
`THEMEMANAGER_SOURCE_DIR=/path/to/thememanager` before running
`just install-tools`. On machines without the local release checkout, set
`THEMEMANAGER_INSTALL_SPEC` to a reachable git tag URL.

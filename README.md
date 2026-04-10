# dotfiles

A collection of my public dotfiles.

## Overview

This repository contains my system configuration, application settings, and installation scripts organized by category:

- **`apps/`** - Application-specific configurations (e.g., Neovim via git submodule)
- **`system/`** - System-level dotfiles and settings
- **`devices/`** - Device-specific configurations
- **`optional/`** - Optional configurations and tweaks
- **`local/`** - Local machine-specific settings
- **`install/`** - Installation scripts organized by privilege boundary
  - **`lib/`** - Shared utilities and step scripts
  - **`system/`** - Privileged phases (packages, system config, device setup)
  - **`user/`** - Unprivileged phases (dotfiles, user services, post-deploy setup)
  - **`extras/`** - Optional add-ons (dev tools, nvim, ly)
  - **`specifics/`** - Device-profile scripts

## Usage

This project uses [just](https://github.com/casey/just) as a task runner. Supported commands:

```bash
just bootstrap [env]      # Full setup: system + user
just system [env]         # Privileged: packages, system config, device setup
just user [env]           # Unprivileged: dotfiles, user services, post-deploy
just extra <name>        # Optional add-ons (dev, nvim, ly)
just unlink [env]         # Remove managed symlinks
just lint                 # Validate package manifests
```

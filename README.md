# dotfiles

A collection of my public dotfiles.

## Overview

This repository contains my system configuration, application settings, and installation scripts organized by category:

- **`apps/`** - Application-specific configurations (e.g., Neovim via git submodule)
- **`system/`** - System-level dotfiles and settings
- **`devices/`** - Device-specific configurations
- **`optional/`** - Optional configurations and tweaks
- **`local/`** - Local machine-specific settings
- **`install/`** - Installation phases and setup scripts

## Usage

This project uses [just](https://github.com/casey/just) as a task runner. Supported commands:

```bash
just bootstrap [env]      # Run bootstrap phase
just preflight            # Check prerequisites
just packages [env]       # Install base packages
just packages-aur [env]   # Install AUR packages (Arch Linux)
just device [env]         # Device-specific setup
just activate [env]       # Activate configuration
just stow-system [env]    # Apply home directory symlinks
just services             # Enable systemd services
just theme                # Set system theme
just pam-u2f              # Setup PAM U2F authentication
just swayfx-nvidia        # Configure Sway with NVIDIA support
```

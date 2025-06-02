# Dotfiles collection

This repository contains my personal dotfiles, symlinking should work out
of the box using `make stow_dotfiles`, (or `make unstow_dotfiles` to undo).

## Symlinking dotfiles

Depencencies for running this Makefile step are:
- make
- stow

### Stow dotfiles
```bash
make stow_dotfiles
```

### Unstow dotfiles
```bash
make unstow_dotfiles
```

## Full system configuration

Dependencies for running the Makefile are:
- make
- stow
- sudo (for pacman)

**OBS: This will probably not work on your computer and might break your system environment. Use at your own risk and disregard the optional env variable at all times.**

Extra dependencies for running the full Makefile are:
- sudo (for pacman)

### All
```bash
make
```

## Environments

- `workstation`
- `laptop`

This will configure specific dotfiles, install packages and settings for the environment.

### Installation (with env variable)
```bash
make env=laptop
```

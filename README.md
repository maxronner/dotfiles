# Dotfiles collection

This repository contains my personal dotfiles.

**OBS: This will probably not work on your computer and might break your system environment. Use at your own risk and disregard the optional env variable at all times.**

Depencencies for running the Makefile are:
- make
- stow
- sudo (for pacman)

## Installation

```bash
make
```

## Stow dotfiles
```bash
make stow_dotfiles
```

## Unstow dotfiles
```bash
make unstow_dotfiles
```

## Environments

- `workstation`
- `laptop`

This will configure specific dotfiles, install packages and settings for the environment.

## Installation (with env variable)
```bash
make env=laptop
```

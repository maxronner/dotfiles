# Dotfiles collection

This repository contains my dotfiles for my personal computers.

**OBS: This wil proabably not work on your machine!**

Depencencies for running the Makefile are:
- make
- stow
- sudo (for pacman)

## Environments

- `workstation`
- `laptop`

This will configure specific dotfiles, install packages and settings for the environment.


## Installation
```bash
make env=laptop
```

## Stow dotfiles
```bash
make stow_dotfiles
```

## Unstow dotfiles
```bash
make unstow_dotfiles
```

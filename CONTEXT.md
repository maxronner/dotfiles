# Dotfiles Context

This context describes desktop theming and wallpaper language used across the dotfiles.

## Language

**Wallpaper Preview**:
A temporary visual wallpaper change used while browsing choices, before committing theme side effects.
_Avoid_: trial wallpaper, temporary set

**Wallpaper Commit**:
A durable wallpaper selection that persists the wallpaper and runs related side effects such as auto palette regeneration and shell reloads.
_Avoid_: wallpaper set, apply wallpaper

**Auto Palette**:
A generated color palette derived from the committed wallpaper when thememanager is in auto mode.
_Avoid_: dynamic theme, wallpaper colors

**Palette Reload**:
The notification that makes running applications consume the latest generated palette artifact.
_Avoid_: refresh theme, sync colors

**Palette Artifact**:
The canonical `palette.json` file consumed by theme adapters. It is versioned and uses Material-style `m3*` UI tokens plus `term*` terminal slots.
_Avoid_: theme JSON, color dump, palette schema

**Package Manifest**:
A `pkg.txt` file owned by an app, system group, device profile, or optional add-on. Each non-empty entry is either a repository package name or an `aur:`-prefixed AUR package name.
_Avoid_: package list, dependency file

**Private Overlay**:
The private dotfiles layer that installs after the public base and can claim the same home-directory targets by unlinking public symlinks before stowing.
_Avoid_: private repo, user config layer

**Thememanager Package**:
The external package installed from the standalone thememanager release tag. It owns Palette Artifact generation, named terminal palettes, and wallpaper-derived Auto Palette generation.
_Avoid_: theme scripts, local theming files

**Git Tool Manifest**:
A pipe-delimited manifest that declares a command installed from a git repository, including its command name, repository URL, ref, and install command.
_Avoid_: clone list, misc package array

## Relationships

- A **Wallpaper Preview** can become a **Wallpaper Commit**.
- A **Wallpaper Commit** may produce an **Auto Palette**.
- An **Auto Palette** writes a **Palette Artifact**.
- A **Palette Artifact** requires a **Palette Reload** before running applications reflect it.
- A **Package Manifest** belongs to one packageable slice and is parsed by the installer before packages are installed.
- The **Private Overlay** is installed after the public base and may override public app dotfiles.
- The **Thememanager Package** writes the **Palette Artifact** consumed by theme adapters.
- A **Git Tool Manifest** belongs to the repo layer that wants those git-installed commands.

## Example dialogue

> **Dev:** "Should navigating the wallpaper picker update the **Auto Palette**?"
> **Domain expert:** "No — navigation is only a **Wallpaper Preview**. The **Auto Palette** updates after **Wallpaper Commit**."

## Flagged ambiguities

- "set wallpaper" was used for both **Wallpaper Preview** and **Wallpaper Commit** — resolved: preview changes only the visible wallpaper, commit also runs side effects.

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

## Relationships

- A **Wallpaper Preview** can become a **Wallpaper Commit**.
- A **Wallpaper Commit** may produce an **Auto Palette**.
- An **Auto Palette** requires a **Palette Reload** before running applications reflect it.

## Example dialogue

> **Dev:** "Should navigating the wallpaper picker update the **Auto Palette**?"
> **Domain expert:** "No — navigation is only a **Wallpaper Preview**. The **Auto Palette** updates after **Wallpaper Commit**."

## Flagged ambiguities

- "set wallpaper" was used for both **Wallpaper Preview** and **Wallpaper Commit** — resolved: preview changes only the visible wallpaper, commit also runs side effects.

# ADR-001: Install Contract

## Status

Accepted.

## Context

The dotfiles are split across a base public repo and window-manager-specific repos such as Hyprland and Sway. The base installer owns shared package collection, local script linking, common stow behavior, and device setup. The window-manager repos add their own app and device layers.

Without a named contract, every repo would need to duplicate install behavior or guess which helpers are safe to call. That would make install changes shallow: small helper edits would leak across multiple repos without a clear Interface.

## Decision

`public/install/lib.sh` is the Install Contract Module for multi-repo stow and device behavior.

The functions in that file are the public Interface for installer adapters:

- `resolve_profile`
- `stow_app`
- `stow_all_apps`
- `stow_device`
- `run_device_setup`
- `ensure_deps`

Window-manager repos may source `install/lib.sh` and call those functions. The base repo may also use them internally.

Do not add, remove, or materially change those functions without updating this ADR. Private install helpers should stay inside the caller script instead of being added to `install/lib.sh` by default.

`public/install/packages.sh` is the Package Manifest Module for package installation behavior. Its Interface is:

- `collect_package_files`
- `collect_packages`
- `validate_package_manifests`
- `ensure_yay`
- `install_repo_packages`
- `install_aur_packages`

Installer adapters may source `install/packages.sh` when they need to parse or install from Package Manifests. Package parsing, `aur:` handling, duplicate removal, and manifest validation should stay in this module instead of being reimplemented by phase scripts, extras, or private overlays.

## Consequences

The Install Contract stays small and stable. Window-manager installers get Leverage from a shared stow/device setup Interface, while Locality stays in the base repo for common install behavior.

Package Manifest behavior has its own small Interface. Base install, extras, and private overlays get consistent `aur:` support and validation without copying parser logic.

New install behavior starts local to the repo or script that needs it. It graduates into `install/lib.sh` only when there are at least two real adapters using the same behavior.

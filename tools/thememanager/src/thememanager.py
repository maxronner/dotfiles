#!/usr/bin/env python3
"""
Palette producer for the theming system.

Generates palette.json from color256 .txt palette files (named themes) or
from the current wallpaper via matugen (auto mode). After writing the palette,
optionally triggers theme-apply-all to render per-app configs.

Usage:
- `thememanager list`: List available themes.
- `thememanager get`: Show the current theme.
- `thememanager set <theme_name>`: Switch to a named theme.
- `thememanager set auto`: Enable wallpaper-based auto mode.
- `thememanager auto [--wallpaper /path/to/image]`: Regenerate palette from wallpaper.
- `thememanager -v set <theme_name>`: Set theme with debug logging.
"""

import argparse
import fcntl
import importlib.metadata
import json
import logging
import math
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

# Configure logging (default level ERROR)
logging.basicConfig(
    level=logging.ERROR,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger(__name__)

# Define base paths
HOME = Path.home()
THEME_MANAGER_DIR = Path(
    os.environ.get("THEME_MANAGER_DIR", HOME / ".config" / "thememanager")
)
XDG_DATA_HOME = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local" / "share"))
PALETTE_FILE = XDG_DATA_HOME / "theme" / "palette.json"
COLOR256_THEMES_DIR = HOME / ".local" / "share" / "themes"


# ---------------------------------------------------------------------------
# LCH colour helpers (CIE LAB, D65 illuminant — same as color256.py)
# ---------------------------------------------------------------------------


def _hex_to_lch(hex_str):
    """Convert a hex colour string to CIE LCH (L, C, H in degrees)."""
    h = hex_str.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)

    # sRGB → linear
    def linearize(c):
        c /= 255.0
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    rl, gl, bl = linearize(r), linearize(g), linearize(b)
    # linear RGB → XYZ (D65)
    X = rl * 0.4124564 + gl * 0.3575761 + bl * 0.1804375
    Y = rl * 0.2126729 + gl * 0.7151522 + bl * 0.0721750
    Z = rl * 0.0193339 + gl * 0.1191920 + bl * 0.9503041

    # XYZ → LAB
    def f(t):
        return t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116

    L = 116 * f(Y / 1.00000) - 16
    a = 500 * (f(X / 0.95047) - f(Y / 1.00000))
    b_ = 200 * (f(Y / 1.00000) - f(Z / 1.08883))
    C = math.sqrt(a**2 + b_**2)
    H = math.degrees(math.atan2(b_, a)) % 360
    return L, C, H


def _lch_to_hex(L, C, H):
    """Convert CIE LCH back to a hex colour string, clamping to sRGB gamut."""
    a = C * math.cos(math.radians(H))
    b_ = C * math.sin(math.radians(H))
    # LAB → XYZ
    fy = (L + 16) / 116
    fx = a / 500 + fy
    fz = fy - b_ / 200

    def finv(t):
        return t**3 if t > 0.206897 else (t - 16 / 116) / 7.787

    X = finv(fx) * 0.95047
    Y = finv(fy) * 1.00000
    Z = finv(fz) * 1.08883
    # XYZ → linear RGB
    rl = 3.2404542 * X - 1.5371385 * Y - 0.4985314 * Z
    gl = -0.9692660 * X + 1.8760108 * Y + 0.0415560 * Z
    bl = 0.0556434 * X - 0.2040259 * Y + 1.0572252 * Z

    # linear → sRGB (clamp to [0, 1])
    def gamma(c):
        c = max(0.0, min(1.0, c))
        return 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055

    r, g, b = (round(gamma(c) * 255) for c in (rl, gl, bl))
    return "#%02x%02x%02x" % (r, g, b)


def _hex_to_rgb(hex_str):
    h = hex_str.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def _rgb_to_hex(r, g, b):
    return "#%02x%02x%02x" % (
        max(0, min(255, r)),
        max(0, min(255, g)),
        max(0, min(255, b)),
    )


def _compute_wallpaper_luminance(image_path):
    """Compute perceptual luminance of an image using ImageMagick.

    Returns a float 0.0-1.0, or None if computation fails.
    """
    try:
        result = subprocess.run(
            ["convert", str(image_path), "-resize", "1x1!", "-format", "%[fx:luminance]", "info:"],
            capture_output=True, text=True, timeout=10,
        )
        if result.returncode == 0 and result.stdout.strip():
            return float(result.stdout.strip())
    except (subprocess.TimeoutExpired, ValueError, FileNotFoundError):
        pass
    return None


def _blend_hex(a, b, amount):
    """Blend two #rrggbb colours by amount of b."""
    ar, ag, ab = _hex_to_rgb(a)
    br, bg, bb = _hex_to_rgb(b)
    return _rgb_to_hex(
        round(ar + (br - ar) * amount),
        round(ag + (bg - ag) * amount),
        round(ab + (bb - ab) * amount),
    )


def _relative_luminance_hex(color):
    r, g, b = [v / 255 for v in _hex_to_rgb(color)]

    def linear(channel):
        if channel <= 0.03928:
            return channel / 12.92
        return ((channel + 0.055) / 1.055) ** 2.4

    return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)


def _on_color(base):
    if _relative_luminance_hex(base) > 0.4:
        return _blend_hex(base, "#000000", 0.8)
    return _blend_hex(base, "#ffffff", 0.85)


def _container(base, bg):
    return _blend_hex(base, bg, 0.65)


def _on_container(base, fg):
    return _blend_hex(base, fg, 0.3)


def _build_palette_artifact(base16_hex, theme_name, terminal_palette_text=None):
    """Build the v2 Palette Artifact written to palette.json.

    base16_hex is a dict with keys: background, foreground, color0..color15
    (hex strings with leading #).
    """
    bg = base16_hex["background"]
    fg = base16_hex["foreground"]
    colors = [base16_hex[f"color{i}"] for i in range(16)]
    primary = colors[4]
    secondary = colors[5]
    tertiary = colors[3]
    error = colors[1]
    success = colors[2]
    muted = colors[8]

    palette = {
        "version": 2,
        "themeName": theme_name,
        "m3primary": primary,
        "m3onPrimary": _on_color(primary),
        "m3primaryContainer": _container(primary, bg),
        "m3onPrimaryContainer": _on_container(primary, fg),
        "m3secondary": secondary,
        "m3onSecondary": _on_color(secondary),
        "m3secondaryContainer": _container(secondary, bg),
        "m3onSecondaryContainer": _on_container(secondary, fg),
        "m3tertiary": tertiary,
        "m3onTertiary": _on_color(tertiary),
        "m3tertiaryContainer": _container(tertiary, bg),
        "m3onTertiaryContainer": _on_container(tertiary, fg),
        "m3error": error,
        "m3onError": _on_color(error),
        "m3errorContainer": _container(error, bg),
        "m3onErrorContainer": _on_container(error, fg),
        "m3success": success,
        "m3onSuccess": _on_color(success),
        "m3successContainer": _container(success, bg),
        "m3onSuccessContainer": _on_container(success, fg),
        "m3surface": bg,
        "m3onSurface": fg,
        "m3onSurfaceVariant": _blend_hex(fg, muted, 0.35),
        "m3outline": muted,
        "m3outlineVariant": _blend_hex(muted, bg, 0.5),
        "m3scrim": "#000000",
        "m3shadow": "#000000",
    }

    for i, color in enumerate(colors):
        palette[f"term{i}"] = color

    if terminal_palette_text:
        for line in terminal_palette_text.splitlines():
            if line.startswith("palette"):
                parts = line.split("=")
                if len(parts) >= 3:
                    try:
                        index = int(parts[1].strip())
                    except ValueError:
                        continue
                    palette[f"term{index}"] = parts[2].strip()

    return palette


def _hue_rotate_base16(base16, source_hex):
    """Re-space the 6 chromatic ANSI hues equidistantly around the colour wheel.

    The wallpaper's dominant hue (from matugen's source_color) provides the
    initial L and C for each slot.  The hue is then rotated so that slot 1
    (offset 0°, red) always lands nearest to 0° on the hue wheel, preserving
    baseline's slot-to-hue contract regardless of wallpaper dominant hue.
    The remaining 5 chromatic slots are assigned hues 60° apart in hue-wheel
    order (red → yellow → green → cyan → blue → magenta).  Lightness and
    chroma are preserved from the original matugen colours so the wallpaper's
    tonal character is retained.  Neutral slots (0, 7, 8, 15, background,
    foreground) are left untouched.

    Minimum lightness and chroma floors are enforced so that matugen's often
    desaturated dark-mode roles produce visible, colourful terminal colours.
    """
    _, _, H0 = _hex_to_lch(source_hex)

    # Rotate H0 so that slot 1 (offset 0°) always lands nearest red (0°).
    # This preserves equidistant spacing while anchoring the ladder to baseline's
    # hue order regardless of wallpaper dominant hue.  H0 becomes 0° after this.
    correction = -H0 if H0 <= 180 else (360 - H0)
    H0 = (H0 + correction) % 360

    # Chromatic slots in hue-wheel order, paired with their bright counterparts
    # and the hue offset (multiples of 60°) from the anchor (always 0°).
    chromatic_slots = [
        ("color1", "color9", 0),  # red
        ("color3", "color11", 60),  # yellow
        ("color2", "color10", 120),  # green
        ("color6", "color14", 180),  # cyan
        ("color4", "color12", 240),  # blue
        ("color5", "color13", 300),  # magenta
    ]

    # Minimum lightness / chroma so colours stay vivid on a dark background.
    MIN_L_DIM = 55
    MIN_L_BRIGHT = 70
    MIN_C = 35

    result = dict(base16)
    for dim, bright, offset in chromatic_slots:
        target_H = (H0 + offset) % 360
        for slot in (dim, bright):
            if slot not in result:
                continue
            L, C, _ = _hex_to_lch(result[slot])
            min_L = MIN_L_BRIGHT if slot == bright else MIN_L_DIM
            L = max(L, min_L)
            C = max(C, MIN_C)
            result[slot] = _lch_to_hex(L, C, target_H)

    return result


def _base16_from_matugen_colors(colors):
    """Map matugen colour roles into the base16 input for the Palette Artifact.

    This is the pure Auto Palette derivation step. It intentionally stops before
    color256 expansion, file writes, and Palette Reload side effects.
    """

    def pick(name, fallback="#000000"):
        value = colors.get(name, {})
        return value.get("default") or value.get("dark") or fallback

    base16 = {
        # Backgrounds / neutrals
        "background": pick("background", "#101010"),
        "foreground": pick("on_background", "#e0e0e0"),
        "color0": pick("surface_dim", "#0d0d0d"),  # black  — darkest bg shade
        "color7": pick("on_surface_variant", "#c0c0c0"),  # white  — near-fg light
        "color8": pick("outline", "#767676"),  # bright black — mid grey
        "color15": pick("on_surface", "#ffffff"),  # bright white — brightest fg
        # Chromatic slots: matugen role provides initial L and C only.
        # Hue is overridden by _hue_rotate_base16 so slot 1 always lands at
        # red (0°) regardless of wallpaper.  Slots follow baseline offset order.
        "color1": pick("error", "#ff6b6b"),  # red       → hue overridden to 0°
        "color9": pick("on_error_container", "#ff9b9b"),  # bright red → 0°
        "color2": pick("tertiary", "#7bd88f"),  # green     → hue overridden to 120°
        "color10": pick("tertiary_fixed_dim", "#a0d8a0"),  # bright green → 120°
        "color3": pick("tertiary_fixed", "#f6c177"),  # yellow   → hue overridden to 60°
        "color11": pick("on_tertiary_container", "#ffd8a0"),  # bright yellow → 60°
        "color4": pick("primary", "#7aa2f7"),  # blue      → hue overridden to 240°
        "color12": pick("on_primary_container", "#7aa2f7"),  # bright blue → 240°
        "color5": pick("secondary", "#bb9af7"),  # magenta  → hue overridden to 300°
        "color13": pick("on_secondary_container", "#bb9af7"),  # bright magenta → 300°
        "color6": pick("outline_variant", "#7dcfff"),  # cyan    → hue overridden to 180°
        "color14": pick("secondary_fixed_dim", "#a0e0e0"),  # bright cyan → 180°
    }

    # Lift neutral slots so the background isn't near-black. Matugen's
    # dark-mode surface roles often land at L≈5-8; ~15-18 reads as dark
    # without being a black hole.
    neutral_floors = {
        "background": 15,
        "color0": 12,
        "color8": 40,
        "color7": 70,
        "foreground": 80,
        "color15": 90,
    }
    for slot, min_L in neutral_floors.items():
        L, C, H = _hex_to_lch(base16[slot])
        if L < min_L:
            base16[slot] = _lch_to_hex(min_L, C, H)

    # Rotate chromatic hues so slot 1 lands at red (0°), then space the
    # remaining 5 slots 60° apart around the wheel. This guarantees the
    # baseline slot-to-hue contract regardless of wallpaper dominant hue,
    # while preserving L and C from the matugen roles above.
    source_hex = pick("source_color", "#cc0403")
    return _hue_rotate_base16(base16, source_hex)


class ThemeManager:
    """Manages theme application and configuration."""

    def __init__(self, dry_run=False):
        self.dry_run = dry_run
        THEME_MANAGER_DIR.mkdir(parents=True, exist_ok=True)

    def _color256_themes_dir(self):
        env_dir = os.environ.get("COLOR256_THEMES_DIR")
        if env_dir:
            return Path(os.path.expanduser(env_dir))
        return COLOR256_THEMES_DIR

    def _list_color256_theme_files(self):
        themes_dir = self._color256_themes_dir()
        if not themes_dir.is_dir():
            return {}
        out = {}
        for entry in themes_dir.iterdir():
            if not entry.is_file() or entry.suffix != ".txt":
                continue
            out[entry.stem] = entry
        return dict(sorted(out.items(), key=lambda item: item[0]))

    def _palette_from_color256_theme(self, theme_path, theme_name=None):
        """Build a palette dict from a color256 theme file.

        Calls color256.py --generate ghostty once to get the full 256-colour
        terminal palette string.  The 16 base colours and bg/fg are parsed
        from that same output so no second subprocess is needed.
        """
        cmd = self._color256_cmd() + ["--generate", "ghostty", str(theme_path)]
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        ghostty_text = result.stdout.strip()

        # Parse bg, fg and color0..color15 out of the ghostty output.
        base16_hex = {}
        for line in ghostty_text.splitlines():
            line = line.strip()
            if line.startswith("background"):
                base16_hex["background"] = line.split("=", 1)[1].strip()
            elif line.startswith("foreground"):
                base16_hex["foreground"] = line.split("=", 1)[1].strip()
            elif line.startswith("palette"):
                # "palette = N = #rrggbb"
                parts = line.split("=")
                idx = int(parts[1].strip())
                if 0 <= idx <= 15:
                    base16_hex[f"color{idx}"] = parts[2].strip()

        return _build_palette_artifact(
            base16_hex,
            theme_name or theme_path.stem,
            terminal_palette_text=ghostty_text,
        )

    @staticmethod
    def _color256_cmd():
        raw = os.environ.get("COLOR256_CMD", "color256.py")
        cmd = shlex.split(raw)
        if not cmd:
            raise FileNotFoundError("COLOR256_CMD is empty")

        exe = os.path.expanduser(cmd[0])
        if os.path.sep in exe:
            exe_path = Path(exe)
            if not exe_path.is_file():
                raise FileNotFoundError(f"color256 command not found: {exe_path}")
            cmd[0] = str(exe_path)
            return cmd

        resolved = shutil.which(exe)
        if not resolved and exe == "color256.py":
            resolved = shutil.which("color256")
        if not resolved:
            raise FileNotFoundError(
                "color256.py command not found in PATH. Set COLOR256_CMD if needed."
            )
        cmd[0] = resolved
        return cmd

    def _palette_from_matugen(self, wallpaper_path):
        colors = self._matugen_colors_from_wallpaper(wallpaper_path)
        palette = self._palette_from_base16(
            _base16_from_matugen_colors(colors),
            theme_name="auto",
        )
        palette["wallpaper"] = str(wallpaper_path)
        return palette

    def _matugen_colors_from_wallpaper(self, wallpaper_path):
        cmd = [
            "matugen",
            "image",
            "-j",
            "hex",
            "-m",
            "dark",
            "--old-json-output",
            "--source-color-index",
            "0",
            str(wallpaper_path),
        ]
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        payload = json.loads(result.stdout)
        return payload.get("colors", {})

    def _palette_from_base16(self, base16, theme_name):
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as tmp:
            tmp.write(json.dumps(base16))
            tmp_path = Path(tmp.name)

        try:
            return self._palette_from_color256_theme(tmp_path, theme_name=theme_name)
        finally:
            tmp_path.unlink(missing_ok=True)

    def list_themes(self):
        """Return a list of available theme names."""
        themes = {"auto"}
        themes.update(self._list_color256_theme_files().keys())
        themes = sorted(themes, key=lambda t: (t != "auto", t))
        logger.debug(f"Found themes: {themes}")
        return themes

    def get_current_theme(self):
        """Return the name of the currently active theme."""
        if PALETTE_FILE.is_file():
            try:
                current = json.loads(PALETTE_FILE.read_text()).get("themeName", "none")
                logger.debug(f"Current theme: {current}")
                return current
            except (json.JSONDecodeError, OSError):
                pass
        return "none"

    def set_theme(self, theme_name):
        """Set the system-wide theme to the one specified."""
        if theme_name == "auto":
            self.auto_theme_from_wallpaper(force=True)
            return

        theme_files = self._list_color256_theme_files()
        theme_path = theme_files.get(theme_name)
        if not theme_path:
            logger.error(
                f"Theme '{theme_name}' not found in {self._color256_themes_dir()}"
            )
            return

        try:
            palette = self._palette_from_color256_theme(
                theme_path, theme_name=theme_name
            )
        except (
            FileNotFoundError,
            subprocess.CalledProcessError,
            json.JSONDecodeError,
        ) as e:
            logger.error(f"Failed to build palette for '{theme_name}': {e}")
            return

        logger.info(f"Setting theme to '{theme_name}'...")
        self._write_and_apply(palette)

    def auto_theme_from_wallpaper(self, wallpaper=None, force=False):
        current = self.get_current_theme()
        if current != "auto" and not force:
            logger.info(
                f"Current theme is '{current}', not 'auto'; skipping wallpaper-based theming."
            )
            return

        wallpaper_path = self._resolve_wallpaper_path(wallpaper)
        if not wallpaper_path:
            logger.warning("No wallpaper found; skipping wallpaper-based theming.")
            return
        if not wallpaper_path.is_file():
            logger.warning(f"Wallpaper file not found: {wallpaper_path}")
            return

        try:
            palette = self._palette_from_matugen(wallpaper_path)
        except (
            subprocess.CalledProcessError,
            json.JSONDecodeError,
            FileNotFoundError,
        ) as e:
            logger.error(f"Failed to generate auto palette: {e}")
            return

        logger.info("Applying wallpaper-based auto theme...")
        self._write_and_apply(palette)

    def _resolve_wallpaper_path(self, wallpaper=None):
        candidates = []
        if wallpaper:
            candidates.append(Path(os.path.expanduser(str(wallpaper))))
        env_wallpaper = os.environ.get("WALLPAPER_IMAGE")
        if env_wallpaper:
            candidates.append(Path(os.path.expanduser(env_wallpaper)))
        candidates.append(HOME / ".local" / "share" / "wallpaper" / "current")

        for candidate in candidates:
            if candidate.is_file():
                return candidate.resolve()
            if candidate.is_symlink() and candidate.exists():
                return candidate.resolve()
        return None

    def _write_and_apply(self, palette):
        """Write palette atomically under lock, then trigger theme-apply-all."""
        lock_path = os.environ.get("XDG_RUNTIME_DIR", "/tmp") + f"/theme.{os.getuid()}.lock"
        lock_fd = os.open(lock_path, os.O_CREAT | os.O_WRONLY)
        fcntl.flock(lock_fd, fcntl.LOCK_EX)
        try:
            PALETTE_FILE.parent.mkdir(parents=True, exist_ok=True)
            # Compute wallpaper luminance if wallpaper path is available
            wallpaper_path = palette.get("wallpaper") or self._resolve_wallpaper_path()
            if wallpaper_path:
                if isinstance(wallpaper_path, str):
                    wallpaper_path = Path(wallpaper_path)
                if wallpaper_path.is_file():
                    lum = _compute_wallpaper_luminance(wallpaper_path)
                    if lum is not None:
                        palette["wallpaperLuminance"] = round(lum, 4)
                        logger.info(f"Wallpaper luminance: {palette['wallpaperLuminance']}")
            content = json.dumps(palette, indent=2) + "\n"
            if self.dry_run:
                logger.info(f"[dry-run] Would write palette to {PALETTE_FILE}")
            else:
                tmp = PALETTE_FILE.with_suffix(".tmp")
                tmp.write_text(content)
                tmp.rename(PALETTE_FILE)

            if not self.dry_run:
                apply_cmd = shutil.which("theme-apply-all")
                if apply_cmd:
                    logger.info("Running theme-apply-all...")
                    env = os.environ.copy()
                    env["THEME_LOCK_HELD"] = "1"
                    subprocess.run([apply_cmd], check=False, env=env)
                else:
                    logger.debug("theme-apply-all not found, skipping apply")
        finally:
            fcntl.flock(lock_fd, fcntl.LOCK_UN)
            os.close(lock_fd)


def _extract_global_flags(argv):
    verbose = 0
    dry_run = False
    remaining = []

    for arg in argv:
        if arg == "--dry-run":
            dry_run = True
            continue
        if arg in ("-v", "--verbose"):
            verbose += 1
            continue
        if re.fullmatch(r"-v{2,}", arg):
            verbose += len(arg) - 1
            continue
        remaining.append(arg)

    return verbose, dry_run, remaining


def main():
    """Parse command-line arguments and execute the corresponding action."""
    extracted_verbose, extracted_dry_run, argv = _extract_global_flags(sys.argv[1:])

    parser = argparse.ArgumentParser(description="Manage application themes.")
    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Increase verbosity (use -v, -vv for more)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making any changes.",
    )
    parser.add_argument(
        "--version",
        action="store_true",
        help="Show package version and exit.",
    )

    if "--version" in argv:
        try:
            print(importlib.metadata.version("thememanager"))
        except importlib.metadata.PackageNotFoundError:
            print("source")
        return

    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("list", help="List all available themes.")
    subparsers.add_parser("get", help="Get the current theme name.")
    set_parser = subparsers.add_parser("set", help="Set the active theme.")
    set_parser.add_argument("theme", help="The name of the theme to set.")
    auto_parser = subparsers.add_parser(
        "auto", help="Apply wallpaper-based theming (only when current theme is auto)."
    )
    auto_parser.add_argument(
        "--wallpaper", help="Wallpaper image path to use for palette extraction."
    )
    auto_parser.add_argument(
        "--force",
        action="store_true",
        help="Apply wallpaper-based theming even if current theme is not auto.",
    )
    args = parser.parse_args(argv)
    args.verbose = extracted_verbose
    args.dry_run = extracted_dry_run

    # Adjust logging level based on verbosity
    if args.verbose == 1:
        logger.setLevel(logging.INFO)
    elif args.verbose == 2:
        logger.setLevel(logging.DEBUG)
    elif args.verbose >= 3:
        logger.setLevel(logging.NOTSET)
    else:
        logger.setLevel(logging.ERROR)

    manager = ThemeManager(dry_run=args.dry_run)

    if args.command == "list":
        themes = manager.list_themes()
        if themes:
            for t in themes:
                print(t)
        else:
            logger.warning(f"No themes found in '{manager._color256_themes_dir()}'")
    elif args.command == "get":
        print(manager.get_current_theme())
    elif args.command == "set":
        manager.set_theme(args.theme)
    elif args.command == "auto":
        manager.auto_theme_from_wallpaper(wallpaper=args.wallpaper, force=args.force)


if __name__ == "__main__":
    main()
